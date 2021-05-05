//
//  ContentView.swift
//  Honeymoon
//
//  Created by Stanly Shiyanovskiy on 26.04.2021.
//

import SwiftUI

struct ContentView: View {
    
    @State
    var showAlert: Bool = false
    
    @State
    var showGuide: Bool = false
    
    @State
    var showInfo: Bool = false
    
    @GestureState
    private var dragState = DragState.inactive
    
    private var dragAreaThreshold: CGFloat = 65.0
    
    @State
    private var lastCardIndex: Int = 1
    
    @State
    private var cardRemovalTransition = AnyTransition.trailingBottom
    
    @State
    var cardViews: [CardView] = {
        var views = [CardView]()
        for index in 0..<2 {
            views.append(CardView(honeymoon: honeymoonData[index]))
        }
        return views
    }()
    
    enum DragState {
        case inactive, pressing, dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .inactive, .pressing:
                return false
            case .dragging:
                return true
            }
        }
        
        var isPressing: Bool {
            switch self {
            case .inactive:
                return false
            case .pressing, .dragging:
                return true
            }
        }
    }
    
    var body: some View {
        VStack {
            
            HeaderView(showGuideView: $showGuide, showInfoView: $showInfo)
                .opacity(dragState.isDragging ? 0 : 1)
                .animation(.default)
            
            Spacer()
            
            ZStack {
                ForEach(cardViews) { cardView in
                    cardView
                        .zIndex(isTopCard(cardView: cardView) ? 1 : 0)
                        .overlay(
                            ZStack {
                                Image(systemName: "x.circle")
                                    .modifier(SymbolModifier())
                                    .opacity(dragState.translation.width < -dragAreaThreshold && isTopCard(cardView: cardView) ? 1 : 0)
                                
                                Image(systemName: "heart.circle")
                                    .modifier(SymbolModifier())
                                    .opacity(dragState.translation.width > dragAreaThreshold && isTopCard(cardView: cardView) ? 1 : 0)
                            }
                        )
                        .offset(x: isTopCard(cardView: cardView) ? dragState.translation.width : 0,
                                y: isTopCard(cardView: cardView) ? dragState.translation.height : 0)
                        .scaleEffect(dragState.isDragging && isTopCard(cardView: cardView) ? 0.85 : 1)
                        .rotationEffect(Angle(degrees: isTopCard(cardView: cardView) ?  Double(dragState.translation.width / 12) : 0))
                        .animation(.interpolatingSpring(stiffness: 120, damping: 120))
                        .gesture(LongPressGesture(minimumDuration: 0.01)
                                    .sequenced(before: DragGesture())
                                    .updating($dragState, body: { value, state, transaction in
                                        switch value {
                                        case .first(true):
                                            state = .pressing
                                        case .second(true, let drag):
                                            state = .dragging(translation: drag?.translation ?? .zero)
                                        default:
                                            break
                                        }
                                    })
                                    .onChanged({ value in
                                        guard case .second(true, let drag?) = value else { return }
                                        
                                        if drag.translation.width < -dragAreaThreshold {
                                            cardRemovalTransition = .leadingBottom
                                        }
                                        
                                        if drag.translation.width > dragAreaThreshold {
                                            cardRemovalTransition = .trailingBottom
                                        }
                                    })
                                    .onEnded({ value in
                                        guard case .second(true, let drag?) = value else { return }
                                        
                                        if drag.translation.width < -dragAreaThreshold || drag.translation.width > dragAreaThreshold {
                                            playSound(sound: "sound-rise", type: "mp3")
                                            moveCards()
                                        }
                                    })
                        ).transition(cardRemovalTransition)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            FooterView(showBookingAlert: $showAlert)
                .opacity(dragState.isDragging ? 0 : 1)
                .animation(.default)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("SUCCESS"),
                message: Text("Wishing a lovely and most precious of the times together for the amazing couple."),
                dismissButton: .default(Text("Happy Honeymoon!")))
        }
    }
    
    private func isTopCard(cardView: CardView) -> Bool {
        guard let index = cardViews.firstIndex(where: { $0.id == cardView.id }) else { return false }
        
        return index == 0
    }
    
    private func moveCards() {
        cardViews.removeFirst()
        
        lastCardIndex += 1
        
        let honeymoon = honeymoonData[lastCardIndex % honeymoonData.count]
        
        let newCardView = CardView(honeymoon: honeymoon)
        
        cardViews.append(newCardView)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
