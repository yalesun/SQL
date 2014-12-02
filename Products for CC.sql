SELECT *
FROM   (SELECT p.id                                                    AS
               'product_id',
               u.id                                                    AS
               'creator_id',
               'sold'                                                  AS
               'status',
               Convert_tz(p.created_at, '+00:00', 'America/Chicago')   AS
               "listed_at",
               Convert_tz(o.completed_at, '+00:00', 'America/Chicago') AS
               "sold_at",
               p.name,
               v.cost_price,
               i.price,
               Sum(Ifnull(t.amount, 0))                                AS
               "payout"
        FROM   line_items i
               JOIN orders o
                 ON i.order_id = o.id
               JOIN variants v
                 ON i.variant_id = v.id
               JOIN products p
                 ON v.product_id = p.id
               JOIN users u
                 ON p.creator_id = u.id
               LEFT OUTER JOIN user_account_managers um
                            ON u.id = um.user_id
                               AND o.completed_at >= um.start_date
                               AND ( o.completed_at < um.end_date
                                      OR um.end_date IS NULL )
               LEFT OUTER JOIN users am
                            ON um.account_manager_id = am.id
               LEFT OUTER JOIN transactions t
                            ON t.line_item_id = i.id
        WHERE  TRUE
           AND i.quantity = 1
           AND o.state = 'complete'
           AND ( t.status NOT IN ( 'canceled', 'cancelled' )
                  OR t.id IS NULL )
           AND Date(Convert_tz(p.created_at, '+00:00', 'America/Chicago')) >=
               '2014-01-01'
        GROUP  BY i.id
        UNION ALL
        SELECT p.product_id                                          AS
               'product_id',
               u.id                                                  AS
               'creator_id',
               'listed'                                              AS 'status'
               ,
               Convert_tz(p.created_at, '+00:00',
               'America/Chicago') AS "listed_at",
               'listed'                                              AS
               "sold_at",
               p.name,
               p.value,
               p.price,
               '0'                                                   AS "payout"
        FROM   product_summaries p
               JOIN users u
                 ON p.creator_id = u.id
        WHERE  TRUE
           AND p.extended_status = 'listed'
           AND Date(Convert_tz(p.created_at, '+00:00', 'America/Chicago')) >
               '2014-01-01') AS t;