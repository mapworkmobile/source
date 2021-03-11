//
//  Login.swift
//  Mapwork
//
//  Created by James Nebeker on 2/27/21.
//

import SwiftUI



struct Login: View {
    func phoneNumberIsEmpty(phoneNumber phoneNum: String) -> Bool {
        
        return phoneNum.isEmpty
        
    }
    func makePrettyPhoneNumber(phoneNumber phoneNum: String)->String {
        
        // format as (xxx) xxx-xxxx
        
        var prettyPhoneNumber = phoneNum
        prettyPhoneNumber.insert("(", at: phoneNum.startIndex)
        
        prettyPhoneNumber.insert( ")", at: prettyPhoneNumber.index(prettyPhoneNumber.startIndex, offsetBy: 4))
        
        prettyPhoneNumber.insert("-", at:
            prettyPhoneNumber.index(prettyPhoneNumber.startIndex, offsetBy: 5))
        
        prettyPhoneNumber.insert("-", at:
            prettyPhoneNumber.index(prettyPhoneNumber.startIndex, offsetBy: 9))
        return prettyPhoneNumber
        
    }
    func phoneNumberContainsLetters(phoneNumber phoneNum: String) -> Bool {
        
        return phoneNum.rangeOfCharacter(from: NSCharacterSet.letters) != nil ? true : false
        
    }
    
    func returnPhoneNumberNoHyphens(phoneNumber phoneNum: String) -> String {
        
        return phoneNum.replacingOccurrences(of: "-", with: "")
        
    }
    
    func appendHyphenToPhoneNumber(phoneNumber phoneNum:String) -> String {
        
        return phoneNum.appending("-")
        
    }
    
    func phoneNumberIsTenCharacters(phoneNumber phoneNum: String) ->  Bool {
        
        return phoneNum.count == 10 ? true : false
        
    }
    func inputIsValidPhoneNumber(phoneNumber phoneNum: String) -> Bool {
        
        let phoneNumberWithoutHyphensOrParens=removePrettyFormatting(phoneNumber: phoneNum)
        
        return (!phoneNumberIsEmpty(phoneNumber: phoneNumberWithoutHyphensOrParens) && !phoneNumberContainsLetters(phoneNumber: phoneNumberWithoutHyphensOrParens) && phoneNumberIsTenCharacters(phoneNumber: phoneNumberWithoutHyphensOrParens))
        
    }
    
    func removePrettyFormatting(phoneNumber phoneNum: String) -> String {
        
        return phoneNum.filter { $0.isNumber }
        
        
    }
    @EnvironmentObject var sessionManager: SessionManager
    
    @State var usernameAndPhoneNumber: String = ""
    @State var userClickedInfoButton = false
    @State var inputDidPassClientSideValidation = false
    @State var inputDidPassServerSideValidation = true
    @State var countryCode = "+01"
    
    var body: some View {
       
        ZStack {
            
            Image("MapworkSplashBackground").resizable().scaledToFill().edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
           
            VStack {
                Text("What's your number?")
                    .font(.custom("Palatino", size: 24, relativeTo: .largeTitle))
                    .foregroundColor(Color.white)
                
                HStack {
                    Text("We'll send you a text with a login code")
                        .font(.custom("Gill Sans", size: 17, relativeTo: .largeTitle))
                        .foregroundColor(Color.white)
                    
                    Button (action:{ userClickedInfoButton.toggle() }){
                        Image(systemName: userClickedInfoButton == true ? "info.circle.fill" : "info.circle").foregroundColor(.white)
                    }
                }.padding()
                
                
                ZStack {
                    
                    
                    TextField("(123)-212-1234", text: $usernameAndPhoneNumber)
                        .onChange(of: inputIsValidPhoneNumber(phoneNumber: usernameAndPhoneNumber)) { newValue in
                            inputDidPassClientSideValidation = newValue
                        }
                        .onChange(of: usernameAndPhoneNumber, perform: { newValue in
                            guard usernameAndPhoneNumber.count==10
                            else {  return }
                            
                            usernameAndPhoneNumber=makePrettyPhoneNumber(phoneNumber: usernameAndPhoneNumber)
                        })
                        .font(.largeTitle)
                        .background(Color.white)
                        .cornerRadius(10)
                        .accentColor(.white)
                        .foregroundColor(Color("MapworkDarkerPink"))
                        .shadow(radius:2, x: 5,y: 5)
                        .frame(width: 300)
                       
                    
                    Menu  {
                        Button(action: {  countryCode = "+01"}) {
                            Label("+1", image: "AmericanFlag")
                        }
                        
                    } label: {
                        Image( "AmericanFlag").resizable().scaledToFit().frame(width: 35, height: 35)
                    }
                    .padding(.trailing, 250)
                }
                
                HStack {
                
                   
                    if inputDidPassClientSideValidation {
                        
                       
                            
        
                      
                            Button(action: {
                                usernameAndPhoneNumber = removePrettyFormatting(phoneNumber: usernameAndPhoneNumber)
                                sessionManager.signIn(username: countryCode + usernameAndPhoneNumber)
                                
                            }) {
                                Text("Send code")
                                    .foregroundColor(Color("MapworkGreen"))
                                    .font(Font.system(.body).smallCaps()).bold()
                            }
                        
                    } else {
                        
                        Text("Please enter a phone number")
                    }
                    
                    if !inputDidPassServerSideValidation {
                        Button(action: {}) {
                            Text("Resend Verification")
                                .foregroundColor(Color("MapworkBaseBlue"))
                                .font(Font.system(.body).smallCaps()).bold()
                                
                        }
                    } else {
                        Button(action: {}) {
                            Text("Resend Verification")
                                .foregroundColor(Color("MapworkBaseBlue"))
                                .font(Font.system(.body).smallCaps()).bold().hidden()
                                
                        }
                    }
                    
                }.padding()
            }.alert(isPresented: $userClickedInfoButton, content: {
                    Alert(title: Text("More Information"), message: Text("Standard SMS rates apply."))
            })
            
           
        }
    }
}

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
