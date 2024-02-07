select
    AVG(EXTRACT(epoch from (modified - created))) as avg_elapsed,
    STDDEV(EXTRACT(
        epoch
        from
        (modified - created)
    )) as std_elapsed,
    MAX(EXTRACT(epoch from (modified - created))) as max_elapsed,
    CONCAT(EXTRACT(
        year
        from
        created
    ),
    '-',
    EXTRACT(
        month
        from
        created
    )) as year_month
from
    clss.t_documents
where
    processstatus = '30'
group by
    year_month
order by
    avg_elapsed asc
