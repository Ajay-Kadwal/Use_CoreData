//
//  TodoList.swift
//  Use_CoreData
//
//  Created by AJAY KADWAL on 03/10/25.
//

import SwiftUI
import CoreData
import Combine

class TodoViewModel: ObservableObject {
    static let shared = TodoViewModel()
    
    let container: NSPersistentContainer
    @Published var savedEntities: [FirstEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "DataModels")
        container.loadPersistentStores { Description, Error in
            if let error = Error {
                print("Error Accuring during load Data!!!.. \(error)")
            } else {
                self.FetchData()
                print("DATA load SucessFully!!")
            }
        }
    }
    
    func FetchData() {
        let request = NSFetchRequest<FirstEntity>(entityName: "FirstEntity")
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch {
            print("Error Accuring During Fetch Request!!")
        }
    }
    
    func AddName(title: String) {
        let newItem = FirstEntity(context: container.viewContext)
        newItem.title = title
        Save()
    }
    
    func Save() {
        do {
            try container.viewContext.save()
            FetchData()
        } catch {
            print("Error Accuring During Saving data!!!")
        }
    }
    
    func Delete(offset: IndexSet) {
        for index in offset {
            let index = savedEntities[index]      // find the entity
            container.viewContext.delete(index)   // delete from Core Data
            Save()
        }
    }
    
    func toggleTask(_ task: FirstEntity ) {
        task.isDone.toggle()   // flip true/false
        Save()
    }
}

struct TodoList: View {
    
    @StateObject var todos = TodoViewModel.shared
    @State var newTitle: String = ""
    @State var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 30) {
                TextField("Enter new item here...", text: $newTitle)
                    .padding()
                    .background(.gray.opacity(0.3))
                    .cornerRadius(10)
                
                Button("ADD") {
                    if !newTitle.isEmpty {
                        todos.AddName(title: newTitle)
                        newTitle = ""
                    } else {
                        showAlert = true
                    }
                }
                .font(.title3)
                .bold()
                .foregroundStyle(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(10)
                
            }
            .padding()
            List {
                
                    ForEach(todos.savedEntities) { data in
                        HStack {
                            Text(data.title ?? "No Data!!")
                            Spacer()
                            Image(systemName: data.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(data.isDone ? .green : .red)
                        }
                        .onTapGesture {
                            todos.toggleTask(data)
                        }
                    }
                    .onDelete { indexSet in
                        todos.Delete(offset: indexSet)
                    }
                
            }
            .navigationTitle("ToDoItems:")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                EditButton()
                    .font(.title)
                    .bold()
            }
        }
        .alert("Enter Appropriate text ‼️", isPresented: $showAlert, actions: {})
    }
}

#Preview {
    TodoList()
}
