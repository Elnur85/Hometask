with payments_without_user as (
select
*
from
payments
where
user_id_sender not in (

select user_id from blacklist
)

),
currencies_excluded as (
select
*
from
currencies
where
end_date is null
),
rates as (
select
*
from
currency_rates
),
formatted_table as (
select
pwu.*,
r.*
from
payments_without_user as pwu

inner join currencies_excluded as ce on pwu.currency = ce.currency_id
left join rates as r on pwu.currency = r.currency_id
and pwu.transaction_date = r.exchange_date

),

pln_converted as (
select f.*,
CASE WHEN currency = 222 THEN (amount * exchange_rate_to_eur)
ELSE amount
END as converted_amount
from formatted_table as f
)
select transaction_date,
round(sum(converted_amount),2) as total_amount
from pln_converted
group by 1;