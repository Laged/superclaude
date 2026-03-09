import { createTodoList } from "./todo";

const todos = createTodoList();

todos.add("Learn Bun");
todos.add("Build something cool");
todos.add("Write tests");

todos.toggle(1);
todos.toggle(3);

console.log("All:", todos.list());
console.log("Done:", todos.completed());
console.log("Pending:", todos.pending());
