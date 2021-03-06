//
//  TodayTodoView.swift
//  TodoList
//
//  Created by 尹毓康 on 2020/1/7.
//  Copyright © 2020 yukangyin. All rights reserved.
//

import SwiftUI

import SwiftUI


struct TodoInTodayView: View {
    // @Environment的作用是从环境中取出预定义的值
    // 从实体中获取数据的属性
    @Environment(\.managedObjectContext) var managedObjectContext
    // 依照dueDate的大小升序排列
    @FetchRequest(entity: TodoItem.entity(), sortDescriptors: [NSSortDescriptor(key: "dueDate", ascending: true)]) var todoItems: FetchedResults<TodoItem> // todoItems的类型是FetchedResults<TodoItem>

    @State private var newToDoItemDetail = ""

    // 是否正在添加代办事项的标志，默认没有正在添加
    @State private var addingTodoItem = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "YY-MM-dd"
        return formatter
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VStack {
                        Text("Today's Todo List")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                        Text("\(self.countTodoInToday()) items")
                                .foregroundColor(.gray)
                    }
                    Spacer()
                }
                        .padding(.leading, 70)


                ScrollView {
                    ForEach(0 ..< todoItems.count, id:\.self) { index in
                        VStack {
                            if self.dateFormatter.string(from: self.todoItems[index].dueDate) == self.dateFormatter.string(from: Date()) {
                                HStack {
                                    Spacer().frame(width: 5)



                                    // 仅显示每一条TodoItem的detail和dueDate，不显示是否被check
                                    TodoItemView(checked: self.todoItems[index].checked, dueDate: self.todoItems[index].dueDate, detail: self.todoItems[index].detail, index: index)
                                    Spacer().frame(width: 35)

                                    // 显示是否被check的按钮,点击按钮即为check(删除该事项)
                                    Button(action: {
                                        // 删除待办事项
                                        let todoItem = self.todoItems[index]
                                        self.managedObjectContext.delete(todoItem)
                                        self.saveTodoItem()
                                    }) {
                                        HStack {
                                            Spacer()
                                            VStack {
                                                Spacer().frame(width: 5)
                                                Image(systemName: "square")
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                        .foregroundColor(Color.gray)
                                                Spacer().frame(width: 5)
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }

                        }
                    }
                }
                        .padding()
            }
            // 右下角的添加事项的加号
            Button(action: {
                // editingTodoItem取反
                self.addingTodoItem.toggle()
            }) {
                btnAdd()
            }.sheet(isPresented: $addingTodoItem) {
                AddTodoItemView()
                        .environment(\.managedObjectContext, (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
            }.offset(x: UIScreen.main.bounds.width/2 - 70, y: UIScreen.main.bounds.height/2 - 130).animation(.spring())
        }
                .padding(.top, 80)
                .padding(.bottom, 83)
    }

    func saveTodoItem() {
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }

    // 计算今日due的事项的个数
    func countTodoInToday() -> Int {

        var num: Int = 0
        for todoItem in self.todoItems {
            if self.dateFormatter.string(from: todoItem.dueDate) == self.dateFormatter.string(from: Date()){
                num = num + 1
            }
        }
        return num
    }
}

//struct btnAdd: View {
//    var size: CGFloat = 65.0
//    var body: some View {
//        ZStack {
//            Group {
//                Circle()
//                    .fill(Color("btnAdd-bg"))
//            }.frame(width: self.size, height: self.size)
//                .shadow(color: Color("btnAdd-shadow"), radius: 10)
//            Group {
//                Image(systemName: "plus.circle.fill")
//                    .resizable()
//                    .frame(width: size, height: size)
//                    .foregroundColor(Color("theme"))
//            }
//        }
//    }
//}


struct TodoInTodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodoInTodayView()
    }
}
