import { beforeEach, describe, expect, test } from "bun:test";
import { createTodoList } from "../todo";

describe("createTodoList", () => {
  let todos: ReturnType<typeof createTodoList>;

  beforeEach(() => {
    todos = createTodoList();
  });

  describe("add", () => {
    test("should create a todo with auto-incrementing id", () => {
      const first = todos.add("First");
      const second = todos.add("Second");
      expect(first.id).toBe(1);
      expect(second.id).toBe(2);
    });

    test("should default to not completed", () => {
      const todo = todos.add("New");
      expect(todo.completed).toBe(false);
    });

    test("should trim whitespace from title", () => {
      const todo = todos.add("  spaces  ");
      expect(todo.title).toBe("spaces");
    });

    test("should reject empty titles", () => {
      expect(() => todos.add("")).toThrow("Title cannot be empty");
      expect(() => todos.add("   ")).toThrow("Title cannot be empty");
    });
  });

  describe("toggle", () => {
    test("should mark pending as completed", () => {
      todos.add("Task");
      const toggled = todos.toggle(1);
      expect(toggled?.completed).toBe(true);
    });

    test("should mark completed as pending", () => {
      todos.add("Task");
      todos.toggle(1);
      const toggled = todos.toggle(1);
      expect(toggled?.completed).toBe(false);
    });

    test("should return undefined for non-existent id", () => {
      expect(todos.toggle(999)).toBeUndefined();
    });
  });

  describe("remove", () => {
    test("should remove and return true", () => {
      todos.add("Task");
      expect(todos.remove(1)).toBe(true);
      expect(todos.list()).toHaveLength(0);
    });

    test("should return false for non-existent id", () => {
      expect(todos.remove(999)).toBe(false);
    });
  });

  describe("list / completed / pending", () => {
    beforeEach(() => {
      const done = todos.add("Done task");
      todos.add("Pending task");
      todos.toggle(done.id);
    });

    test("should return all todos", () => {
      expect(todos.list()).toHaveLength(2);
    });

    test("should return a defensive copy", () => {
      const snapshot = todos.list();
      todos.add("Extra");
      expect(snapshot).toHaveLength(2);
    });

    test("should filter completed", () => {
      const result = todos.completed();
      expect(result).toHaveLength(1);
      expect(result[0]?.title).toBe("Done task");
    });

    test("should filter pending", () => {
      const result = todos.pending();
      expect(result).toHaveLength(1);
      expect(result[0]?.title).toBe("Pending task");
    });
  });

  describe("clear", () => {
    test("should remove all todos and reset ids", () => {
      todos.add("Task");
      todos.clear();
      expect(todos.list()).toHaveLength(0);
      expect(todos.add("Fresh").id).toBe(1);
    });
  });
});
