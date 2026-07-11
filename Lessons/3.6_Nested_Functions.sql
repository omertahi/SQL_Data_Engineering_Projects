-- Array Intro

-- simple array of integers
SELECT [1, 2, 3];

-- simple array of varchars
SELECT ['python', 'sql', 'r'];

-- build array from regular column containing multiple rows/values
WITH skills AS (
    SELECT 
        'python' AS skill
    UNION ALL
    SELECT 
        'sql'
    UNION ALL
    SELECT 
        'r'
)
SELECT LIST(skill) AS skills_array
FROM skills;

-- remember to ORDER BY in LIST()/ARRAY_AGG() function to maintain order
WITH skills AS (
    SELECT 
        'python' AS skill
    UNION ALL
    SELECT 
        'sql'
    UNION ALL
    SELECT 
        'r'
), skills_array AS (
    SELECT LIST(skill ORDER BY skill) AS skills
    FROM skills
)
SELECT
    skills[1] AS first_skill,
    skills[2] AS second_skill,
    skills[3] AS third_skill
FROM skills_array;

-- STRUCT Intro

-- simple struct of varchars
SELECT {skill: 'python', type: 'programming'} AS skill_struct;

-- build struct using STRUCT_PACK()
SELECT
    STRUCT_PACK(
        skill := 'python',
        type := 'programming'
    ) AS s;

-- access key-values in struct via dot notation struct.struct_key
WITH skills_struct AS (
    SELECT
        STRUCT_PACK(
            skill := 'python',
            type := 'programming'
        ) AS s
)
SELECT
    s.skill,
    s.type
FROM skills_struct;

-- build struct from table of multiple columns
WITH skill_table AS (
    SELECT 
        'python' AS skills,
        'programming' AS types
    UNION ALL
    SELECT 
        'sql',
        'query_language'
    UNION ALL
    SELECT 
        'r' ,
        'programming'
)
SELECT
    STRUCT_PACK(
        skill := skills,
        type := types
    )
FROM skill_table;



-- Array of Structs

-- simple array of structs
SELECT [
    { skill: 'python', type: 'programming' },
    { skill: 'sql', type: 'query_language' }
] AS skills_array_of_structs;

-- build array of structs from column containing structs as its values
WITH skill_table AS (
    SELECT 
        'python' AS skills,
        'programming' AS types
    UNION ALL
    SELECT 
        'sql',
        'query_language'
    UNION ALL
    SELECT 
        'r' ,
        'programming'
)
SELECT
    LIST(
        STRUCT_PACK(
            skill := skills,
            type := types
        )
    )
FROM skill_table;


-- access individual structs from array of structs via list[] notation
WITH skill_table AS (
    SELECT 
        'python' AS skills,
        'programming' AS types
    UNION ALL
    SELECT 
        'sql',
        'query_language'
    UNION ALL
    SELECT 
        'r',
        'programming'
), skills_array_struct AS (
    SELECT
        LIST(
            STRUCT_PACK (
                skill := skills,
                type := types
            )
        ) AS array_struct
    FROM skill_table
)
SELECT
    array_struct[1],
    array_struct[2],
    array_struct[3]
FROM skills_array_struct;


-- access individual key-values from each struct in array of structs via list_column[item_#].struct_key
WITH skill_table AS (
    SELECT 
        'python' AS skills,
        'programming' AS types
    UNION ALL
    SELECT 
        'sql',
        'query_language'
    UNION ALL
    SELECT 
        'r',
        'programming'
), skills_array_struct AS (
    SELECT
        LIST(
            STRUCT_PACK (
                skill := skills,
                type := types
            )
        ) AS array_struct
    FROM skill_table
)
SELECT
    array_struct[1].skill,
    array_struct[2].type,
    array_struct[3]
FROM skills_array_struct;


-- MAP INTRO

-- simple map
SELECT MAP {'skill':'python', 'type':'programming'} AS map_col;

-- access key-values from keys in MAP using map['key']
WITH skill_map AS (
    SELECT MAP {'skill':'python', 'type': 'programming'} AS map_col
)
SELECT
    map_col['skill'], 
    map_col['type']
FROM
    skill_map;


-- JSON INTRO

-- JSON
SELECT
    '{"skill": "python", "type": "programming"}'::JSON AS skill_json;


-- table with JSON as column value
WITH raw_skill_json AS (
    SELECT
        '{"skill": "python", "type": "programming"}'::JSON AS skill_json
)
SELECT
    skill_json
FROM raw_skill_json;


-- converting JSON to STRUCT
WITH raw_skill_json AS (
    SELECT
        '{"skill": "python", "type": "programming"}'::JSON AS skill_json
)
SELECT
    STRUCT_PACK(
        skill := json_extract_string(skill_json, '$.skill'),
        type := json_extract_string(skill_json, '$.type')
    )
FROM raw_skill_json;


-- JSON to Array of Structs
WITH raw_json AS (
SELECT
    '[
        {"skill": "python", "type": "programming"},
        {"skill": "sql", "type": "query_language"},
        {"skill":"r", "type": "programming"}
    ]':: JSON AS skills_json
)
SELECT
    LIST(
        STRUCT_PACK(
            skill := json_extract_string(e.value, '$.skill'),
            type := json_extract_string(e.value, '$.type')
        )
        ORDER BY json_extract_string(e.value, '$.skill')
    ) AS skills
FROM raw_json, json_each(skills_json) AS e;