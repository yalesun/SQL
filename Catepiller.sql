
select p.user_id, sum(p.paid), sum(p.owed) from 
(select t.user_id, 0 as 'paid', sum(t.amount) as 'owed' from transactions t
where true
and  DATE(convert_tz(t.created_at, '+00:00', 'America/Chicago')) between '2014-08-01' and '2014-08-31'
   AND t.type = 'ItemSoldTransaction'
AND t.status != 'canceled'
group by t.user_id

union all 


select t.user_id, sum(t.amount) as 'paid', 0 as 'owed' from transactions t
where true
and  DATE(convert_tz(t.updated_at, '+00:00', 'America/Chicago')) between '2014-08-01' and '2014-08-31'
   AND t.type != 'ItemSoldTransaction'
AND t.status = 'paid'
group by t.user_id) as p
group by p.user_id
