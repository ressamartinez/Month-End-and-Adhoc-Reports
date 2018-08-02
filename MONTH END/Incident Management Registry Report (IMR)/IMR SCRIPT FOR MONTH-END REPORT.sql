--2403

SELECT temp.IRNo as [IR No.]
			,temp.StatusName as [Issue Status]
			,temp.Description as [Incident Level]
			,temp.Category
			,temp.Title as [Nature of Occurrence]
			,temp.department as [Department]
			,temp.section_name as [Section]
			,temp.Place
			,temp.HN 
			,temp.Incident_Patient_Name as [Incident / Patient Name]
			,temp.Age
			,temp.Gender
			,temp.birth_date as [Date of Birth]
			,temp.email_address as [Email Address]
			,temp.contact_no as [Contact No.]
			,temp.diagnosis as [Diagnosis]
			,temp.Persons_Involved as [Persons Involved]
			,temp.Narrative_Report as [Narrative Report]
			,temp.Root_Cause as [Root Cause]
			,temp.Actions_Taken as [Actions Taken]
			,temp.assignedTo as [Assigned To]
			,temp.Created_Date_Time as [Created Date and Time]
			,temp.Resolved_Date_Time as [Resolved Date and Time]
			,temp.Created_By as [Created By Employee No.]
			,temp.username as [Created By Employee Name]

			--,temp.user_group_name as [Group Name (Group Tagging)] 
			--,temp.username_of_users_in_group [Users in Group (Group Tagging)]
			,temp.user_group_name as [Assigned To Group (Group Tagging)]
FROM (
				SELECT all_ir.IRID
							,all_ir.IRNo
							,issueStat.StatusName
							,incLevel.Description
							,cat.Category
							,nature.Title
							,dept.department
							,sec.section_name
							,all_ir.Place
							,all_ir.HN
							,all_ir.Incident_Patient_Name
							,all_ir.Age
							,all_ir.Gender
							,all_ir.birth_date
							,all_ir.email_address
							,all_ir.contact_no
							,all_ir.diagnosis
							,all_ir.Persons_Involved
							,all_ir.Narrative_Report
							,all_ir.Root_Cause
							,all_ir.Actions_Taken
							,assignedUsers.UsersID
							,ad.display_name as assignedTo
							,all_ir.Created_Date_Time
							,all_ir.Resolved_Date_Time
							,all_ir.Created_By
							,udn.username

							--,gr.user_group_name
							--,adUsersForGroup.user_id as user_id_of_users_in_group
							--,adUsersForGroup.display_name as username_of_users_in_group

							,(SELECT user_group_name from ir.group_ref where group_id = 
									(SELECT top 1 group_id from ir.group_for_tagging_ref where irid = all_ir.IRID)) as user_group_name

				FROM ir.All_Issues all_ir
								LEFT OUTER JOIN ir.incident_level_ref incLevel ON all_ir.IncLevelID = incLevel.IncLevelID
								LEFT OUTER JOIN ir.issue_status_ref issueStat ON all_ir.StatusID = issueStat.StatusID
								LEFT OUTER JOIN ir.category_ref cat ON all_ir.CatID = cat.CatID
								LEFT OUTER JOIN ir.nature_of_occurrence_ref nature ON all_ir.NocID = nature.NocID
								LEFT OUTER JOIN ir.department_ref dept ON all_ir.DeptID = dept.department_id
								LEFT OUTER JOIN ir.section_ref sec ON all_ir.section_id = sec.section_id
								LEFT OUTER JOIN ir.assigned_users_ref assignedUsers ON all_ir.IRID = assignedUsers.IRID
								LEFT OUTER JOIN ad_users ad ON assignedUsers.UsersID = ad.user_id
								LEFT OUTER JOIN user_display_name udn ON all_ir.Created_By = udn.user_id

								--LEFT OUTER JOIN ir.group_for_tagging_ref gft ON all_ir.IRID = gft.irid
								--LEFT OUTER JOIN ir.group_ref gr ON gft.group_id = gr.group_id
								--LEFT OUTER JOIN ir.user_per_group_ref upg ON gft.group_id = upg.group_id
								--LEFT OUTER JOIN ad_users adUsersForGroup ON upg.user_id = adUsersForGroup.user_id
)as temp


order BY temp.Created_Date_Time
-----------------------------------------------------------------------------

--SELECT * 
--FROM ir.All_Issues a
--				LEFT OUTER JOIN ir.group_for_tagging_ref b ON a.IRID = b.irid
--				LEFT OUTER JOIN ir.group_ref gr ON b.group_id = gr.group_id
--				LEFT OUTER JOIN ir.user_per_group_ref upg ON b.group_id = upg.group_id
--				LEFT OUTER JOIN ad_users adUsersForGroup ON upg.user_id = adUsersForGroup.user_id
--order by a.IRNo


--SELECT * FROM ir.group_for_tagging_ref
--SELECT * FROM ir.group_ref
--SELECT * FROM ir.user_per_group_ref


--SELECT DISTINCT gft.irid 
--			,gr.user_group_name
--			,adUsersInGroup.display_name
			
--FROM ir.group_for_tagging_ref gft
--				LEFT OUTER JOIN ir.group_ref gr ON gft.group_id = gr.group_id
--				LEFT OUTER JOIN ir.user_per_group_ref upg ON upg.group_id = gr.group_id
--				LEFT OUTER JOIN ad_users adUsersInGroup ON upg.user_id = adUsersInGroup.user_id
--order by gft.irid



