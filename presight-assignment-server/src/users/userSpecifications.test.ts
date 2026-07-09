import { describe, expect, it } from "vitest";
import {
  buildUserFilterSpecification,
  whereHasAllHobbies,
} from "./userSpecifications.js";
import { mergeSpecifications } from "../pagination/specification.js";

describe("userSpecifications", () => {
  it("builds text, nationality OR, and hobby AND filters together", () => {
    const fragment = buildUserFilterSpecification({
      q: "ann",
      nationalities: ["German", "French"],
      hobbies: ["Reading", "Hiking"],
    }).toSql();

    expect(fragment?.sql).toContain("u.first_name ILIKE");
    expect(fragment?.sql).toContain("u.nationality IN");
    expect(fragment?.sql).toContain("COUNT(DISTINCT h.name)");
    expect(fragment?.values).toEqual([
      "%ann%",
      "%ann%",
      "German",
      "French",
      "Reading",
      "Hiking",
      2,
    ]);
  });

  it("requires users to have all selected hobbies", () => {
    const fragment = whereHasAllHobbies("u", ["Reading", "Cooking"]).toSql();

    expect(fragment).toEqual({
      sql: `(
          SELECT COUNT(DISTINCT h.name)
          FROM user_hobbies uh
          JOIN hobbies h ON h.id = uh.hobby_id
          WHERE uh.user_id = u.id
            AND h.name IN ($1, $2)
        ) = $3`,
      values: ["Reading", "Cooking", 2],
    });
  });

  it("ignores empty filter values", () => {
    const fragment = mergeSpecifications(
      buildUserFilterSpecification({
        nationalities: [],
        hobbies: [],
      }),
    );

    expect(fragment).toBeNull();
  });
});
