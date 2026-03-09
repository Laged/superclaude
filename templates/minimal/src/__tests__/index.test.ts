import { describe, expect, test } from "bun:test";
import { greet } from "../index";

describe("greet", () => {
  test("should return greeting with name", () => {
    expect(greet("world")).toBe("Hello, world!");
  });
});
