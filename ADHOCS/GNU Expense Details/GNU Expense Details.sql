SELECT tempb.costcentre_code,
		tempb.costcentre,
		tempb.gl_acct_code_code,
		tempb.gl_acct_name,
		tempb.item_code,
		tempb.item_name,
		cast(tempb.qty as NUMERIC(12,0)) as qty,
		tempb.auc,
		tempb.category
from
(
	SELECT temp.costcentre_code,
			temp.costcentre,
			temp.gl_acct_code_code,
			temp.gl_acct_name,
			temp.item_code,
			temp.item_name,
			SUM(temp.requested_qty) as qty,
			sum(temp.auc) as auc,
			'PIMI' as category
	from
	(
		SELECT cc.costcentre_code,
				cc.name_l as costcentre, 
				sprd.item_id,
				i.item_code,
				i.name_l as item_name,
			   case WHEN ISNULL(id.issued_qty,0) = 0 then sprd.requested_qty else id.issued_qty end as requested_qty,
				(case WHEN ISNULL(id.issued_qty,0) = 0 then sprd.requested_qty else id.issued_qty end) * ISNULL((SELECT top 1 CAST(average_unit_cost as NUMERIC(12,2))
																												from item_cost
																												where item_id = sprd.item_id
																													and start_date_time <= sprd.lu_updated
																												order by start_date_time DESC
																												),0) as auc,
					i.item_type_rcd,
					i.sub_item_type_rcd,
					system_transaction_type_rcd,
					gac.gl_acct_code_code,
					gac.name_l as gl_acct_name
		from swe_purchase_request_nl_view spr inner JOIN swe_purchase_request_detail_nl_view sprd on spr.purchase_request_id = sprd.purchase_request_id
												inner JOIN user_transaction_type utt on spr.user_transaction_type_id = utt.user_transaction_type_id
												inner JOIN costcentre cc on sprd.costcentre_id = cc.costcentre_id
												INNER JOIN item i on sprd.item_id = i.item_id
												inner JOIN item_group_gl igg on i.item_group_id = igg.item_group_id
												inner JOIN gl_acct_code gac on igg.gl_acct_code_id = gac.gl_acct_code_id
												LEFT outer JOIN issue_detail id on sprd.purchase_request_detail_id = id.purchase_request_detail_id
		where MONTH(id.lu_updated) = @Month
				and YEAR(id.lu_updated) = @Year
				and system_transaction_type_rcd = 'PREQ'
			and sprd.swe_purchase_status_rcd in ('COM')
				and sprd.void_transaction_id is NULL
				and cc.costcentre_code in ('6080',
											'6082',
											'6090',
											'6092',
											'6093',
											'6094',
											'6095',
											'6120',
											'6160')
					and (SELECT (SELECT  gl_tree2.parent_acct_code_id
								from gl_acct_code gl_tree2
								where  gl_tree2.gl_acct_code_id = gl_tree3.parent_acct_code_id) as gl_parent_tree1
						from gl_acct_code gl_tree3
						where gl_tree3.company_code = 'ahi'
										and gl_tree3.gl_acct_code_code = gac.gl_acct_code_code) = '75E2273A-F673-11D9-A79A-001143B8816C'
			and i.sub_item_type_rcd IN ('STK')
			and igg.item_account_type_rcd = 'ISSUE_EXPENSE'
			and sprd.void_transaction_id is NULL
	) as temp
	GROUP BY  temp.costcentre_code,
			temp.costcentre,
			temp.gl_acct_code_code,
			temp.gl_acct_name,
			temp.item_code,
			temp.item_name
	UNION ALL
	SELECT cc.costcentre_code,
			cc.name_l as costcentre,
			gac.gl_acct_code_code,
			gac.name_l as gl_acct_name,
			'' as item_code,
			gld.description as item_name,
			ISNULL(gld.quantity,0)  as qty,
			case WHEN ISNULL(gld.debit_flag,0) = 1 then gld.amount else -gld.amount END as auc,
			'GJV' as category
	from gl_transaction gl inner JOIN user_transaction_type utt on gl.user_transaction_type_id = utt.user_transaction_type_id
							inner JOIN gl_transaction_detail gld on gl.gl_transaction_id = gld.gl_transaction_id
							inner join costcentre cc on gld.costcentre_id = cc.costcentre_id
							inner JOIN gl_acct_code gac on gld.gl_acct_code_id = gac.gl_acct_code_id
	where utt.user_transaction_type_code IN ('GJV')
		and MONTH(gl.effective_date) = @Month
		and YEAR(gl.effective_date) = @Year
		and cc.costcentre_code in ('6080',
									'6082',
									'6090',
									'6092',
									'6093',
									'6094',
									'6095',
									'6120',
									'6160')
			and (SELECT (SELECT  gl_tree2.parent_acct_code_id
								from gl_acct_code gl_tree2
								where  gl_tree2.gl_acct_code_id = gl_tree3.parent_acct_code_id) as gl_parent_tree1
						from gl_acct_code gl_tree3
						where gl_tree3.company_code = 'ahi'
										and gl_tree3.gl_acct_code_code = gac.gl_acct_code_code) = '75E2273A-F673-11D9-A79A-001143B8816C'
	
	UNION ALL
	SELECT temp.costcentre_code,
		temp.costcentre,
		temp.gl_acct_code_code,
		temp.gl_acct_name,
		temp.item_code,
		temp.item_name,
		SUM(temp.quantity) as qty,
		SUM(temp.auc) as auc,
		'AP TRAN' as category
	from
	(
		SELECT  aptd.ap_invoice_detail_id,
	    cc.costcentre_code,
		cc.name_l as costcentre,
		cast(CAST(i.item_id as BINARY) as UNIQUEIDENTIFIER) as item_id,
		ISNULL(i.item_code,'') as item_code,
		case when  len(ISNULL(i.name_l,'')) > 0 then i.name_l else (case when LEN(ISNULL(aptd.comment,'')) > 0 then aptd.comment else apt.transaction_comment end) end as item_name,
		ISNULL( aptd.quantity,0) as quantity,
		case when utt.system_transaction_type_rcd = 'CDMP' then aptd.book_received_amount *-1  ELSE aptd.book_received_amount end as auc,
		ISNULL(i.item_type_rcd,'') as item_type_rcd,
		ISNULL(i.sub_item_type_rcd,'') as sub_item_type_rcd,
		utt.system_transaction_type_rcd,
		gac.gl_acct_code_code,
		gac.name_l as gl_acct_name
	from swe_ap_transaction_nl_view apt inner JOIN swe_ap_transaction_detail_nl_view aptd on apt.ap_invoice_id = aptd.ap_invoice_id
										inner JOIN user_transaction_type utt on apt.user_transaction_type_id = utt.user_transaction_type_id
										inner JOIN costcentre cc on aptd.item_costcentre_debit_id = cc.costcentre_id
										inner JOIN gl_acct_code gac on aptd.item_gl_acct_code_debit_id = gac.gl_acct_code_id
										left OUTER join item i on aptd.item_id = i.item_id
	where MONTH(apt.effective_date) = @Month
			and YEAR(apt.effective_date) = @Year
			and cc.costcentre_code in ('6080',
									'6082',
									'6090',
									'6092',
									'6093',
									'6094',
									'6095',
									'6120',
									'6160')
			and (SELECT (SELECT  gl_tree2.parent_acct_code_id
						from gl_acct_code gl_tree2
						where  gl_tree2.gl_acct_code_id = gl_tree3.parent_acct_code_id) as gl_parent_tree1
				from gl_acct_code gl_tree3
				where gl_tree3.company_code = 'ahi'
						and gl_tree3.gl_acct_code_code = gac.gl_acct_code_code) = '75E2273A-F673-11D9-A79A-001143B8816C'
	  and aptd.purchase_distribute_detail_id not in (	SELECT _sprd.purchase_distribute_detail_id
														from swe_purchase_distribute_detail _sprd inner JOIN costcentre _cc on _sprd.costcentre_id = _cc.costcentre_id
																									inner JOIN item _i on _sprd.item_id = _i.item_id
																									inner JOIN item_group_gl _igg on _i.item_group_id = _igg.item_group_id
																									inner JOIN gl_acct_code _gac on _igg.gl_acct_code_id = _gac.gl_acct_code_id
																									inner JOIN swe_purchase_request_detail _spreq on _sprd.purchase_request_detail_id = _spreq.purchase_request_detail_id
														where MONTH(_sprd.lu_updated) = @Month
															and YEAR(_sprd.lu_updated) = @Year
															and cc.costcentre_code in ('6080',
																						'6082',
																						'6090',
																						'6092',
																						'6093',
																						'6094',
																						'6095',
																						'6120',
																						'6160')
																and (SELECT (SELECT  _gl_tree2.parent_acct_code_id
																			from gl_acct_code _gl_tree2
																			where  _gl_tree2.gl_acct_code_id = _gl_tree3.parent_acct_code_id) as gl_parent_tree1
																	from gl_acct_code _gl_tree3
																	where _gl_tree3.company_code = 'ahi'
																					and _gl_tree3.gl_acct_code_code = _gac.gl_acct_code_code) = '75E2273A-F673-11D9-A79A-001143B8816C'
															and _i.sub_item_type_rcd IN ('EXP')
															and _spreq.void_transaction_id is NULL)
	) as temp
	GROUP BY temp.costcentre_code,
				temp.costcentre,
				temp.gl_acct_code_code,
				temp.gl_acct_name,
				temp.item_code,
				temp.item_name
	UNION ALL
	SELECT cc.costcentre_code,
			cc.name_l as costcentre,
			gac.gl_acct_code_code,
			gac.name_l as gl_acct_name,
			'' as item_code,
			case when LEN(gld.description) > 0 then gld.description else utt.name_l end as item_name,
			ISNULL(gld.quantity,0) as qty,
			case when ISNULL(gld.debit_flag,0) = 1 then gld.amount else gld.amount *-1 END as auc,
			'PISC' as category
	from gl_transaction gl inner JOIN user_transaction_type utt on gl.user_transaction_type_id = utt.user_transaction_type_id
							inner JOIN gl_transaction_detail gld on gl.gl_transaction_id = gld.gl_transaction_id
							inner join costcentre cc on gld.costcentre_id = cc.costcentre_id
							inner JOIN gl_acct_code gac on gld.gl_acct_code_id = gac.gl_acct_code_id
	where utt.user_transaction_type_code = 'PISC'
		and MONTH(gl.effective_date) = @Month
		and YEAR(gl.effective_date) = @Year
			and cc.costcentre_code in ('6080',
										'6082',
										'6090',
										'6092',
										'6093',
										'6094',
										'6095',
										'6120',
										'6160')
			and (SELECT (SELECT  gl_tree2.parent_acct_code_id
								from gl_acct_code gl_tree2
								where  gl_tree2.gl_acct_code_id = gl_tree3.parent_acct_code_id) as gl_parent_tree1
						from gl_acct_code gl_tree3
						where gl_tree3.company_code = 'ahi'
										and gl_tree3.gl_acct_code_code = gac.gl_acct_code_code) = '75E2273A-F673-11D9-A79A-001143B8816C'
	 UNION ALL
	 SELECT temp.costcentre_code,
	   temp.costcentre,
	   temp.gl_acct_code_code,
	   temp.gl_acct_name,
	   temp.item_code,
	   temp.item_name,
	   SUM(temp.distributed_qty) as qty,
		sum(temp.auc) as auc,
		'DISTRIBUTE' as category
		from
		(
			SELECT DISTINCT sprd.purchase_distribute_detail_id,
					cc.costcentre_code,
					cc.name_l as costcentre,
					gac.gl_acct_code_code,
					gac.name_l as gl_acct_name,
					i.item_code,
					i.name_l as item_name,
					sprd.distributed_qty,
	   				sprd.distributed_qty * ISNULL((SELECT top 1 CAST(last_unit_cost as NUMERIC(12,2))
													from item_cost
													where item_id = sprd.item_id
														and start_date_time <= sprd.lu_updated
													order by start_date_time DESC
													),0) as auc
			from swe_purchase_distribute_detail sprd inner JOIN costcentre cc on sprd.costcentre_id = cc.costcentre_id
														inner JOIN item i on sprd.item_id = i.item_id
														inner JOIN item_group_gl igg on i.item_group_id = igg.item_group_id
														inner JOIN gl_acct_code gac on igg.gl_acct_code_id = gac.gl_acct_code_id
														inner JOIN swe_purchase_request_detail spreq on sprd.purchase_request_detail_id = spreq.purchase_request_detail_id
			where MONTH(sprd.lu_updated) = @Month
				and YEAR(sprd.lu_updated) = @Year
				and cc.costcentre_code in ('6080',
											'6082',
											'6090',
											'6092',
											'6093',
											'6094',
											'6095',
											'6120',
											'6160')
					and (SELECT (SELECT  gl_tree2.parent_acct_code_id
								from gl_acct_code gl_tree2
								where  gl_tree2.gl_acct_code_id = gl_tree3.parent_acct_code_id) as gl_parent_tree1
						from gl_acct_code gl_tree3
						where gl_tree3.company_code = 'ahi'
										and gl_tree3.gl_acct_code_code = gac.gl_acct_code_code) = '75E2273A-F673-11D9-A79A-001143B8816C'
				and i.sub_item_type_rcd IN ('EXP')
				and spreq.void_transaction_id is NULL
				and igg.item_account_type_rcd = 'ISSUE_EXPENSE'
		) as temp
		GROUP BY  temp.costcentre_code,
				temp.costcentre,
				temp.gl_acct_code_code,
				temp.gl_acct_name,
				temp.item_code,
				temp.item_name

) as tempb
ORDER BY tempb.costcentre_code,tempb.gl_acct_code_code