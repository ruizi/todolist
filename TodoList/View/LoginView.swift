//
//  LoginView.swift
//  TodoList
//
//  Created by 尹毓康 on 2020/1/6.
//  Copyright © 2020 yukangyin. All rights reserved.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct LoginView: View {

    // @Environment的作用是从环境中取出预定义的值
    // 从实体中获取数据的属性
    @Environment(\.managedObjectContext) var managedObjectContext

    // 随便按照username升序排列，获取到所有的User
    // users的长度是1，就是正在使用该app的用户
    @FetchRequest(entity: User.entity(), sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)]) var users: FetchedResults<User>

    @State private var email = ""
    @State private var password = ""

    // 记录用户是否已经注册
    @State private var alreadySignUp = false

    // 记录用户是否忘了密码，如果忘记了密码，该值为true
    @State private var alreadyForgetPassword = false


    var body: some View {
        ZStack {
            Image("designSixBg")
                    .resizable()
            VStack {
                // Logo
                Spacer()
                VStack {
                    Text("Welcome")
                            .scaledFont(name: "RobotoSlab-Bold", size: 34)
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                    Text("Please sign in to continue.")
                            .scaledFont(name: "RobotoSlab-Light", size: 18)
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))

                }
                Spacer()
                //Form
                VStack(alignment: .center, spacing: 30) {
                    VStack(alignment: .center, spacing: 10) {
                        // 输入email和密码
                        VStack(alignment: .center, spacing: 30) {
                            // 输入email
                            VStack(alignment: .center, spacing: 10) {
                                HStack(alignment: .center, spacing: 10) {// input email
                                    Image(systemName: "envelope").foregroundColor(Color.white)
                                            .frame(width: 20, height: 20)
                                    CustomTextField(
                                            placeholder: Text("Email")
                                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))),
                                            text: $email)
                                }
                                Divider()
                                        .background(Color.gray)
                            }

                            // input password
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "lock").foregroundColor(Color.white)
                                            .frame(width: 20, height: 20)
                                    CustomSecureField(
                                            placeholder: Text("Password").foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))),
                                            password: $password
                                    )
                                }
                                Divider()
                                        .background(Color.gray)
                            }
                        }

                        // forgot password
                        HStack {
                            Spacer()
                            Button(action: /*@START_MENU_TOKEN@*/{
                                // add actions
                                self.alreadyForgetPassword.toggle()
                                //ashdiuhaishdiuashdiuahu
                            }/*@END_MENU_TOKEN@*/) {
                                Text("Forgot Password?")
                                        .scaledFont(name: "RobotoSlab-Light", size: 14)
                                        .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                            }.sheet(isPresented: $alreadyForgetPassword) {
                                ForgetPassWordView()
                            }
                        }
                    }
                            .padding(.horizontal, 30)

                    // Button
                    //Spacer.frame(height:10)
                    Button(action: {
//                        if (self.users.count == 0) {
//                            print("没有用户注册这个App")
//                            self.email = ""
//                            self.password = ""
//                            // TODO: 跳出一个弹框：请您先注册
//                        }
//                        else if (self.users.count > 1) {
//                            self.email = ""
//                            self.password = ""
//                            print("此时不止有一名用户在本地登录APP!")
//                        }
//                        else {
                        let parameters: Dictionary = ["email": self.email,
                                                      "password": self.password, ]
                        Alamofire.request("https://ruitsai.tech/login_api/", method: .post, parameters: parameters)
                                .responseJSON { response in
                                    switch response.result.isSuccess {
                                    case true:
                                        if let value = response.result.value {
                                            let json = JSON(value)
                                            let state = json[0]["state"].stringValue
                                            if state == "pass" {
                                                let email = json[0]["email"].stringValue
                                                let password = json[0]["password"].stringValue
                                                let username = json[0]["name"].stringValue

                                                // 把用户的信息存储到数据库中
                                                let newUser = User(context: self.managedObjectContext)
                                                newUser.auth = "authorized"
                                                newUser.email = email
                                                newUser.username = username
                                                newUser.password = password
                                                // 使用CoreData保存
                                                do {
                                                    try self.managedObjectContext.save()
                                                } catch {
                                                    print(error)
                                                }
                                            } else {
                                                // TODO: 跳出一个弹框：账户错误
                                                print("账户错误")
                                            }

                                        } else {
                                            // TODO: 跳出一个弹框：network errors
                                            print("error happened")
                                        }
                                    case false:
                                        print(response.result.error)
                                    }
                                }
                        Alamofire.request("https://ruitsai.tech/records_init_sync_api/", method: .post, parameters: parameters)
                                .responseJSON { response in
                                    switch response.result.isSuccess {
                                    case true:
                                        if let value = response.result.value {
                                            let json = JSON(value)

                                            print(json)
                                            // 把用户的日程信息存入数据库
                                            for (index, subJson): (String, JSON) in json {
                                                let detail = subJson["detail"].stringValue
                                                var Year = subJson["Year"].stringValue
                                                var Month = subJson["Month"].stringValue
                                                var Day = subJson["Day"].stringValue

                                                let timestamp = subJson["timestamp"].stringValue
                                                let newTodoItem = TodoItem(context: self.managedObjectContext)
                                                newTodoItem.detail = detail
                                                newTodoItem.dueDate = Date(year: Int(Year) ?? 2020, month: Int(Month) ?? 01, day: Int(Day) ?? 10)
                                                newTodoItem.checked = false
                                                newTodoItem.timeStamp = timestamp  // 20200108234117
                                                // 使用CoreData保存
                                                do {
                                                    try self.managedObjectContext.save()
                                                } catch {
                                                    print("***")
                                                    print(newTodoItem.detail)
                                                    print(newTodoItem.dueDate)
                                                    print(newTodoItem.checked)
                                                    print(error)
                                                }
                                            }


                                        } else {
                                            // TODO: 跳出一个弹框：network errors
                                            print("error happened")
                                        }
                                    case false:
                                        print(response.result.error)
                                    }
                                }

                    }) {
                        Image(systemName: "arrow.right")
                                .accentColor(Color.white)
                                .font(.headline)
                                .frame(width: 60, height: 60)
                                .background(Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)))
                                .cornerRadius(30)

                    }
                }

                //Footer
                Spacer()
                Button(action: {
                    // alreadySignUp由false到true
                    self.alreadySignUp.toggle()
                }) {
                    Text("Sign up, if you’re new!")
                            .scaledFont(name: "RobotoSlab-Light", size: 18)
                            .foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                }
                        .sheet(isPresented: $alreadySignUp) {
                            SignUpView()
                                    .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
                        }
                        .padding(.bottom, 40)
            }


        }
                .edgesIgnoringSafeArea(.all)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
