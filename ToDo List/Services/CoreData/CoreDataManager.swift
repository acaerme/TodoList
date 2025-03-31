import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    func saveTodos(todos: [Todo]) {
        let context = persistentContainer.viewContext
        
        for todo in todos {
            let todoEntity = TodoEntity(context: context)
            todoEntity.id = todo.id
            todoEntity.todoTitle = todo.title
            todoEntity.todoDescription = todo.description
            todoEntity.date = todo.date
            todoEntity.completed = todo.completed
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save todos: \(error)")
        }
    }
    
    func getAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let todoEntities = try persistentContainer.viewContext.fetch(fetchRequest)
            let todos = todoEntities.map { entity in
                Todo(id: entity.id ?? UUID(),
                     title: entity.todoTitle ?? "",
                     description: entity.todoDescription ?? "",
                     date: entity.date ?? Date(),
                     completed: entity.completed)
            }
            completion(.success(todos))
        } catch {
            completion(.failure(error))
        }
    }
    
    func createTodo(newTodo: Todo) {
        let context = persistentContainer.viewContext
        guard let todoEntity = NSEntityDescription.entity(forEntityName: "TodoEntity", in: context) else {
            fatalError("Failed to create Todo entity description.")
        }
        
        let todo = NSManagedObject(entity: todoEntity, insertInto: context)
        todo.setValue(newTodo.id, forKey: "id")
        todo.setValue(newTodo.title, forKey: "todoTitle")
        todo.setValue(newTodo.description, forKey: "todoDescription")
        todo.setValue(newTodo.date, forKey: "date")
        todo.setValue(newTodo.completed, forKey: "completed")
        
        saveContext()
        
        NotificationCenter.default.post(
            name: Notification.Name("TodoAdded"),
            object: nil,
            userInfo: ["todo": newTodo]
        )
    }
    
    func updateTodo(updatedTodo: Todo) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "TodoEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", updatedTodo.id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let todo = results.first {
                todo.setValue(updatedTodo.title, forKey: "todoTitle")
                todo.setValue(updatedTodo.description, forKey: "todoDescription")
                todo.setValue(Date(), forKey: "date")
                todo.setValue(updatedTodo.completed, forKey: "completed")
                saveContext()
                
                NotificationCenter.default.post(
                    name: Notification.Name("TodoEdited"),
                    object: nil,
                    userInfo: ["todo": updatedTodo]
                )
            }
        } catch {
            print("Failed to update todo: \(error)")
        }
    }
    
    func deleteTodo(id: UUID) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "TodoEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let todo = results.first {
                context.delete(todo)
                saveContext()
                
                NotificationCenter.default.post(
                    name: Notification.Name("TodoDeleted"),
                    object: nil,
                    userInfo: ["todoId": id]
                )
            }
        } catch {
            print("Failed to delete todo: \(error)")
        }
    }
    
    func deleteAllTodos() {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>(entityName: "TodoEntity")

        do {
            let results = try context.fetch(fetchRequest)
            for object in results {
                context.delete(object)
            }
            saveContext()
            
            NotificationCenter.default.post(
                name: Notification.Name("AllTodosDeleted"),
                object: nil
            )
        } catch {
            print("Failed to delete all todos: \(error)")
        }
    }
}
