{%- set selected_fields = [
    "advertiser_id", 
    "id",
    "name",
    "status",
    "daily_spend_cap",
    "updated_time"
] -%}
{%- set schema_name, table_name = 'pinterest_raw_uk', 'campaigns' -%}
{% set raw_tables = dbt_utils.get_relations_by_pattern('pinterest_raw_uk%', 'campaign_history') %}

WITH raw_data AS 
    ({{ dbt_utils.union_relations(relations = raw_tables) }}),

    staging AS 
    (SELECT
    
        {% for field in selected_fields -%}
        {{ get_pinterest_clean_field(table_name, field) }},
        {% endfor -%}
        MAX(updated_time) OVER (PARTITION BY id) as last_updated_time

    FROM raw_data
    )

SELECT *
FROM staging 
WHERE updated_time = last_updated_time
