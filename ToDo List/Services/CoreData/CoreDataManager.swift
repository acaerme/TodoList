import CoreData

class CoreDataManager {
    
    // MARK: - CoreData Stack
    
    let persistentContainer: NSPersistentContainer
    private let backgroundQueue = DispatchQueue(label: "com.todolist.coredata", qos: .userInitiated)
    
    init(persistentContainer: NSPersistentContainer? = nil) {
        if let container = persistentContainer {
            self.persistentContainer = container
        } else {
            self.persistentContainer = NSPersistentContainer(name: "TodoList")
            self.persistentContainer.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load persistent stores: \(error)")
                }
            }
        }
    }
    
    // MARK: - Core Data Saving support
    
    private func saveContext(completion: ((Error?) -> Void)? = nil) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion?(nil)
            } catch {
                let nserror = error as NSError
                completion?(nserror)
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    func saveTodos(todos: [Todo]?, completion: ((Error?) -> Void)? = nil) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.persistentContainer.viewContext
            
            for todo in todos ?? [] {
                let todoEntity = TodoEntity(context: context)
                todoEntity.id = todo.id
                todoEntity.todoTitle = todo.title
                todoEntity.todoDescription = todo.description
                todoEntity.date = todo.date
                todoEntity.completed = todo.completed
            }
            
            self.saveContext(completion: completion)
        }
    }
    
    func getAllTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.persistentContainer.viewContext
            
            do {
                let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
                
                let todoEntities = try context.fetch(fetchRequest)
                let todos = todoEntities.map { entity in
                    Todo(id: entity.id ?? UUID(),
                         title: entity.todoTitle ?? "",
                         description: entity.todoDescription ?? "",
                         date: entity.date ?? Date(),
                         completed: entity.completed)
                }
                
                DispatchQueue.main.async {
                    completion(.success(todos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func createTodo(newTodo: Todo, completion: ((Error?) -> Void)? = nil) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.persistentContainer.viewContext
            
            let todoEntity = TodoEntity(context: context)
            todoEntity.id = newTodo.id
            todoEntity.todoTitle = newTodo.title
            todoEntity.todoDescription = newTodo.description
            todoEntity.date = newTodo.date
            todoEntity.completed = newTodo.completed
            
            self.saveContext { error in
                completion?(error)
            }
        }
    }
    
    func updateTodo(todo: Todo, completion: ((Error?) -> Void)? = nil) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.persistentContainer.viewContext
            
            do {
                let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", todo.id as CVarArg)
                
                let results = try context.fetch(fetchRequest)
                if let todoEntity = results.first {
                    todoEntity.todoTitle = todo.title
                    todoEntity.todoDescription = todo.description
                    todoEntity.date = todo.date
                    todoEntity.completed = todo.completed
                    
                    self.saveContext { error in
                        completion?(error)
                    }
                }
            } catch {
                completion?(error)
            }
        }
    }
    
    func deleteTodo(id: UUID, completion: ((Error?) -> Void)? = nil) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.persistentContainer.viewContext
            
            do {
                let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
                
                let results = try context.fetch(fetchRequest)
                if let todoEntity = results.first {
                    context.delete(todoEntity)
                    self.saveContext { error in
                        completion?(error)
                    }
                }
            } catch {
                completion?(error)
            }
        }
    }
    
    func deleteAllTodos(completion: ((Error?) -> Void)? = nil) {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            let context = self.persistentContainer.viewContext
            
            do {
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TodoEntity.fetchRequest()
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                try context.execute(deleteRequest)
                
                completion?(nil)
                
                self.saveContext()
            } catch {
                completion?(error)
            }
        }
    }
}
