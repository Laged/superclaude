export interface Todo {
  id: number;
  title: string;
  completed: boolean;
}

export function createTodoList() {
  let todos: Todo[] = [];
  let nextId = 1;

  return {
    add(title: string): Todo {
      if (!title.trim()) {
        throw new Error("Title cannot be empty");
      }
      const todo: Todo = { id: nextId++, title: title.trim(), completed: false };
      todos.push(todo);
      return todo;
    },

    toggle(id: number): Todo | undefined {
      const todo = todos.find((t) => t.id === id);
      if (todo) {
        todo.completed = !todo.completed;
      }
      return todo;
    },

    remove(id: number): boolean {
      const index = todos.findIndex((t) => t.id === id);
      if (index === -1) return false;
      todos.splice(index, 1);
      return true;
    },

    list(): readonly Todo[] {
      return [...todos];
    },

    completed(): readonly Todo[] {
      return todos.filter((t) => t.completed);
    },

    pending(): readonly Todo[] {
      return todos.filter((t) => !t.completed);
    },

    clear(): void {
      todos = [];
      nextId = 1;
    },
  };
}
