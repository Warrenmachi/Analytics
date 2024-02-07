with doc_pages as (
select
	df.document_id as doc_id,
	df.created_on as doc_file_created_on,
	MAX(dfp.page_number) as doc_pages
from
	document_file df
inner join document_file_page dfp on
	dfp.file_id = df.id
where
	DATE(df.created_on) >= '2023-01-01'
	--and dfp.status = 'approved'
group by
	df.created_on,
	df.document_id
),
doc_types as (
select
	doc.created_on as document_created_on,
	doc.id,
	doc.document_file_id,
	dt.internal_name
from
	document doc
inner join document_type dt on
	doc.type_id = dt.id
where
	doc.created_on >= '2023-01-01'
	and dt.internal_name is not null
	and doc.document_file_id is not null
)
select
	doc_class,
	doc_count,
	ROUND(avg_pages,
	2) as avg_pages,
	created_year_month
from
	(
	select
		case
			when doc_types.internal_name like 'payslip%' then 'payslip'
			when doc_types.internal_name like 'purchase_contract%' then 'purchase_contract_draft'
			when doc_types.internal_name like 'bank_statement%' then 'bank_statement'
			when doc_types.internal_name like 'land_register%' then 'land_register'
			else doc_types.internal_name
		end as doc_class,
		COUNT(doc_types.document_file_id) as doc_count,
		AVG(doc_pages.doc_pages) as avg_pages,
		CONCAT(extract(year
	from
		DATE_TRUNC('month',
		doc_types.document_created_on)),
		' / ',
		LPAD(extract(month
	from
		DATE_TRUNC('month',
		doc_types.document_created_on))::text,
		2,
		'0')) as created_year_month
	from
		doc_pages
	inner join doc_types on
		doc_pages.doc_id = doc_types.id
	group by
		created_year_month,
		doc_class
) as filtered_docs
WHERE
  doc_class IN ('payslip', 'purchase_contract_draft', 'bank_statement', 'land_register','expose','energy_certificate','passport_or_identification_card')
order by
	created_year_month,
	doc_class