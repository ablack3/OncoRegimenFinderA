drop table if exists  @writeDatabaseSchema.@regimenIngredientTable;

with cte as (
select r.person_id, r.ingredient_start_date as regimen_start_date,
       STRING_AGG(DISTINCT lower(r.concept_name), ',' ORDER BY lower(r.concept_name)) as regimen
from @writeDatabaseSchema.@regimenTable r
group by r.person_id, r.ingredient_start_date
)
select cte.person_id, orig.drug_era_id, i.concept_name as ingredient, i.ingredient_start_date, i.ingredient_end_date,
        cte.regimen, cte.regimen_start_date, max(i.ingredient_end_date) over (partition by cte.regimen_start_date, cte.person_id) as regimen_end_date
into @writeDatabaseSchema.@regimenIngredientTable
from @writeDatabaseSchema.@regimenTable orig
left join cte on cte.person_id = orig.person_id and cte.regimen_start_date = orig.ingredient_start_date
left join @writeDatabaseSchema.@cohortTable i on i.person_id = orig.person_id and i.drug_era_id = orig.drug_era_id
order by cte.person_id, regimen_start_date
