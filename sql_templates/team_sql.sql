SELECT		BRAND_SAFETY.TEAM_ID AS 'Team ID',
			BRAND_SAFETY.TEAM_NAME AS 'Team Name',
			BRAND_SAFETY.CAMPAIGN_NAME AS 'Campaign Name',
            BRAND_SAFETY.PARTNER_NAME AS 'Partner Name',
            BRAND_SAFETY.PLACEMENT_NAME AS 'Placement Name',
            BRAND_SAFETY.DEVICE_TYPE AS 'Device Type',
            BRAND_SAFETY.BLOCKING_STATUS AS 'Blocking Status',
            VIEWABILITY.TOTAL_MEASURED_IMPS AS 'Measured Impressions',
            BRAND_SAFETY.TOTAL_IMPS AS 'Total Impressions',
            VIEWABILITY.TOTAL_MEASURED_RATE AS '% Measured',
            BRAND_SAFETY.SEE_THROUGH_RATE AS '% See-Through',
            BRAND_SAFETY.PASSED_RATE AS '% Passed',
            BRAND_SAFETY.FAILED_RATE AS '% Failed',
            BRAND_SAFETY.FAILED_BY_CONTENT_RATE AS '% Failed by Content',
            BRAND_SAFETY.FAILED_BY_GEO_RATE AS '% Failed by Geo',
            BRAND_SAFETY.FAILED_BY_KEYWORD_RATE AS '% Failed by Keyword',
            BRAND_SAFETY.FAILED_BY_BLACKLIST_RATE AS '% Failed by Blacklist',
            BRAND_SAFETY.FAILED_BY_LANGUAGE_RATE AS '% Failed by Language',
            FRAUD.FRAUD_RATE AS '% Fraud',
            IF(VIEWABILITY.TOTAL_VIEWABLE_RATE >= 0, VIEWABILITY.TOTAL_VIEWABLE_RATE, NULL) AS 'Total Viewable Rate (Total Net Metrics)',
            IF(DISP_VIEWABILITY.TOTAL_VIEWABLE_DISPLAY_RATE >= 0, DISP_VIEWABILITY.TOTAL_VIEWABLE_DISPLAY_RATE, NULL) AS 'Total Viewable Display Rate (Total Net Metrics)',
            IF(VID_VIEWABILITY.TOTAL_VIEWABLE_VIDEO_RATE >= 0, VID_VIEWABILITY.TOTAL_VIEWABLE_VIDEO_RATE, NULL) AS 'Total Viewable Video Rate (Total Net Metrics)',
            IF(VIEWABILITY.GROUPM_DISPLAY_RATE >= 0, VIEWABILITY.GROUPM_DISPLAY_RATE, NULL) AS '% Display Ads In View (GroupM)',
            IF(VIEWABILITY.GROUPM_VIDEO_RATE >= 0, VIEWABILITY.GROUPM_VIDEO_RATE, NULL) AS '% Video Ads In View (GroupM)',
            IF(VIEWABILITY.PUBLICIS_DISPLAY >= 0, VIEWABILITY.PUBLICIS_DISPLAY, NULL) AS '% Display Ads In View (Publicis)',
            IF(VIEWABILITY.PUBLICIS_VIDEO >= 0, VIEWABILITY.PUBLICIS_VIDEO, NULL) AS '% Video Ads In View (Publicis)'
FROM		(
			/******************************************************************************************
			Brand Safety Metrics (AGG_AGENCY_BRANDSAFETY Table)
			******************************************************************************************/
			SELECT		TEAM.ID AS 'TEAM_ID',
						LTRIM(RTRIM(TEAM.NAME)) AS 'TEAM_NAME',								
						'N/A' AS 'CAMPAIGN_NAME',								
						'N/A' AS 'PARTNER_NAME',								
						'N/A' AS 'PLACEMENT_NAME',
						'N/A' AS 'DEVICE_TYPE',
						/*** Metrics ***/
						-- Total Imps
						SUM(GROSS_IMPS) AS 'TOTAL_IMPS',
						-- Blocking Status
						IF(SUM(MONITORING_IMPS)>250 AND SUM(BLOCKING_IMPS)>250,'Mixed',IF((SUM(BLOCKING_IMPS)<250 AND SUM(MONITORING_IMPS)>100*SUM(BLOCKING_IMPS)) OR SUM(BLOCKING_IMPS)=0,'Monitoring',IF((SUM(MONITORING_IMPS)<250 AND SUM(BLOCKING_IMPS)>100*SUM(MONITORING_IMPS)) OR SUM(MONITORING_IMPS)=0,'Blocking','Mixed'))) AS 'BLOCKING_STATUS',
						-- % See-Through
						(SUM(IMPS) - SUM(NON_VISIBLE_IMPS))/SUM(GROSS_IMPS) AS 'SEE_THROUGH_RATE',
						-- % Passed
						SUM(PASSED_IMPS)/SUM(GROSS_IMPS) AS 'PASSED_RATE',
						-- % Failed
						SUM(FAILED_IMPS)/SUM(GROSS_IMPS) AS 'FAILED_RATE',
						-- % Failed by Content
						SUM(FAILED_ARBITRATION_IMPS)/SUM(GROSS_IMPS) AS 'FAILED_BY_CONTENT_RATE',
						-- % Failed by Geo
						SUM(FAILED_GEO_IMPS)/SUM(GROSS_IMPS) AS 'FAILED_BY_GEO_RATE',
						-- % Failed by Keyword
						SUM(FAILED_KEYWORD_IMPS)/SUM(GROSS_IMPS) AS 'FAILED_BY_KEYWORD_RATE',
						-- % Failed by Blacklist
						SUM(FAILED_URL_IMPS)/SUM(GROSS_IMPS) AS 'FAILED_BY_BLACKLIST_RATE',
						-- % Failed by Language
						SUM(FAILED_LANG_IMPS)/SUM(GROSS_IMPS) AS 'FAILED_BY_LANGUAGE_RATE'    
			FROM		analytics.AGG_AGENCY_BRANDSAFETY BRANDSAFETY									
			LEFT JOIN 	analytics.PUBLISHER PUB										
			ON 			BRANDSAFETY.PUBLISHER_ID = PUB.ID								
			LEFT JOIN 	analytics.MEDIA_PARTNER PARTNER										
			ON 			PUB.MEDIA_PARTNER_ID = PARTNER.ID								
			LEFT JOIN	analytics.PLACEMENT PLACEMENT										
			ON			BRANDSAFETY.PLACEMENT_ID = PLACEMENT.ID								
			LEFT JOIN	analytics.ADV_ENTITY ADV										
			ON			BRANDSAFETY.CAMPAIGN_ID = ADV.CAMPAIGN_ID								
			LEFT JOIN	analytics.team TEAM										
			ON			ADV.TEAM_ID = TEAM.ID								
			WHERE 		BRANDSAFETY.CAMPAIGN_ID IN (									
												   SELECT		CAMPAIGN_ID 	
												   FROM 		analytics.ADV_ENTITY 	
												   WHERE 		CAMPAIGN_ID <> 0 	
												   AND 			TEAM_ID IN ({{team_ids}})
												   )			
			AND 		DT >= 20171101									
			AND 		DT <= 20171130									
			-- Exclusion portion: Uncomment out to enable specific exclusions											
			-- AND			CAMPAIGN_NAME NOT IN ()								
			-- AND			PARTNER.NAME NOT IN ()								
			-- AND			PLACEMENT.NAME NOT IN ()								
			GROUP BY	1,2,3,4,5							
			HAVING		SUM(IMPS) > 50000
            ) BRAND_SAFETY
LEFT JOIN	(
			/******************************************************************************************
			Fraud Metrics (AGG_AGENCY_FRAUD Table)
			******************************************************************************************/
			SELECT		TEAM.ID AS 'TEAM_ID',
						LTRIM(RTRIM(TEAM.NAME)) AS 'TEAM_NAME',								
						'N/A' AS 'CAMPAIGN_NAME',								
						'N/A' AS 'PARTNER_NAME',								
						'N/A' AS 'PLACEMENT_NAME',
						'N/A' AS 'DEVICE_TYPE',
						/*** Metrics ***/
						 -- % Fraud
						SUM(GIVT_IMPS+SIVT_IMPS)/SUM(GROSS_IMPS) AS 'FRAUD_RATE'
			FROM		analytics.AGG_AGENCY_FRAUD FRAUD									
			LEFT JOIN 	analytics.PUBLISHER PUB										
			ON 			FRAUD.PUBLISHER_ID = PUB.ID								
			LEFT JOIN 	analytics.MEDIA_PARTNER PARTNER										
			ON 			PUB.MEDIA_PARTNER_ID = PARTNER.ID								
			LEFT JOIN	analytics.PLACEMENT PLACEMENT										
			ON			FRAUD.PLACEMENT_ID = PLACEMENT.ID								
			LEFT JOIN	analytics.ADV_ENTITY ADV										
			ON			FRAUD.CAMPAIGN_ID = ADV.CAMPAIGN_ID								
			LEFT JOIN	analytics.team TEAM										
			ON			ADV.TEAM_ID = TEAM.ID								
			WHERE 		FRAUD.CAMPAIGN_ID IN (									
										     SELECT			CAMPAIGN_ID 	
										     FROM 			analytics.ADV_ENTITY 	
										     WHERE 			CAMPAIGN_ID <> 0 	
										     AND 			TEAM_ID IN ({{team_ids}})
										     )			
			AND 		DT >= 20171101									
			AND 		DT <= 20171130									
			-- Exclusion portion: Uncomment out to enable specific exclusions											
			-- AND			CAMPAIGN_NAME NOT IN ()								
			-- AND			PARTNER.NAME NOT IN ()								
			-- AND			PLACEMENT.NAME NOT IN ()								
			GROUP BY	1,2,3,4,5							
			HAVING		SUM(IMPS) > 50000
            ) FRAUD
ON			BRAND_SAFETY.TEAM_ID = FRAUD.TEAM_ID
AND			BRAND_SAFETY.TEAM_NAME = FRAUD.TEAM_NAME
AND			BRAND_SAFETY.CAMPAIGN_NAME = FRAUD.CAMPAIGN_NAME
AND			BRAND_SAFETY.PARTNER_NAME = FRAUD.PARTNER_NAME
AND			BRAND_SAFETY.PLACEMENT_NAME = FRAUD.PLACEMENT_NAME
AND			BRAND_SAFETY.DEVICE_TYPE = FRAUD.DEVICE_TYPE
LEFT JOIN	(
			/******************************************************************************************
			Viewability Metrics (AGG_AGENCY_QUALITY_V3 Table)
			******************************************************************************************/
			SELECT		TEAM.ID AS 'TEAM_ID',
						LTRIM(RTRIM(TEAM.NAME)) AS 'TEAM_NAME',								
						'N/A' AS 'CAMPAIGN_NAME',								
						'N/A' AS 'PARTNER_NAME',								
						'N/A' AS 'PLACEMENT_NAME',
						'N/A' AS 'DEVICE_TYPE',
						/*** Metrics ***/
						-- Measured Imps
						ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))))+ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0)))) AS 'TOTAL_MEASURED_IMPS',
						-- % Measured
						(ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))))+ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0)))))
						/ SUM(COALESCE(PASSED_IMPS,0) + COALESCE(FLAGGED_IMPS,0) - COALESCE(SUSPICIOUS_PASSED_IMPS,0) - COALESCE(SUSPICIOUS_FLAGGED_IMPS,0)) AS 'TOTAL_MEASURED_RATE',
						-- Total Viewable Rate (Total Net Metrics)
						ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))))
						/ (ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0)))) + ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))))) AS 'TOTAL_VIEWABLE_RATE',
						-- Total Out of View % (Total Net Metrics)
						ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))))
						/ SUM(COALESCE(PASSED_IMPS,0) + COALESCE(FLAGGED_IMPS,0) - COALESCE(SUSPICIOUS_PASSED_IMPS,0) - COALESCE(SUSPICIOUS_FLAGGED_IMPS,0)) AS 'TOTAL_OUT_OF_VIEW_RATE',
						-- % Display Ads Fully In View (GroupM)
						(SUM(IF(COALESCE(MEDIA_TYPE_ID, 1) IN (1, 4, 5, 6, 111, 121, 131, 221, 231) AND VIDEO_FL = 0,IF(MCM_1_SRC = 2,(MCM_1_NON_SUSPICIOUS_IMPS + MCM_1_SUSPICIOUS_IMPS),0) * (IF(Q_DATA_IMPS > IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0)) * IMPS / Q_DATA_IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))) + COALESCE(SUSPICIOUS_PASSED_IMPS,0) + COALESCE(SUSPICIOUS_FLAGGED_IMPS,0)) / IMPS,0))
						/ SUM(IF(COALESCE(MEDIA_TYPE_ID, 1) IN (1, 4, 5, 6, 111, 121, 131, 221, 231) AND VIDEO_FL = 0,COALESCE(PASSED_IMPS,0) + COALESCE(FLAGGED_IMPS,0),0))) AS 'GROUPM_DISPLAY_RATE',
						-- % Videos Fully In View (GroupM)
						(SUM(IF(COALESCE(MEDIA_TYPE_ID, 1) IN (2, 3, 112, 122, 132, 222, 232) AND VIDEO_FL = 1,IF(MCM_1_SRC = 2,(MCM_1_NON_SUSPICIOUS_IMPS + MCM_1_SUSPICIOUS_IMPS),0) * (IF(Q_DATA_IMPS > IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0)) * IMPS / Q_DATA_IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))) + COALESCE(SUSPICIOUS_PASSED_IMPS,0) + COALESCE(SUSPICIOUS_FLAGGED_IMPS,0)) / IMPS,0))
						/ SUM(IF(COALESCE(MEDIA_TYPE_ID, 1) IN (2, 3, 112, 122, 132, 222, 232) AND VIDEO_FL = 1,COALESCE(PASSED_IMPS,0) + COALESCE(FLAGGED_IMPS,0),0))) AS 'GROUPM_VIDEO_RATE',
                        -- Publicis Display Rate
                        SUM(IF( COALESCE(MEDIA_TYPE_ID, 1) IN (1, 4, 5, 6, 111, 121, 131, 221, 231) AND VIDEO_FL = 0,IF(MCM_1_SRC = 1,(MCM_1_NON_SUSPICIOUS_IMPS + MCM_1_SUSPICIOUS_IMPS),0) * (IF(Q_DATA_IMPS > IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0)) * IMPS / Q_DATA_IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))) + COALESCE(SUSPICIOUS_PASSED_IMPS,0) + COALESCE(SUSPICIOUS_FLAGGED_IMPS,0)) / IMPS, 0))
						/ SUM(IF(COALESCE(MEDIA_TYPE_ID, 1) IN (1, 4, 5, 6, 111, 121, 131, 221, 231) AND VIDEO_FL = 0,COALESCE(PASSED_IMPS,0) + COALESCE(FLAGGED_IMPS,0),0)) AS 'PUBLICIS_DISPLAY',
                        -- Publicis Video Rate
                        SUM(IF(COALESCE(MEDIA_TYPE_ID, 1) IN (2, 3, 112, 122, 132, 222, 232) AND VIDEO_FL = 1,IF(MCM_1_SRC = 1,(MCM_1_NON_SUSPICIOUS_IMPS + MCM_1_SUSPICIOUS_IMPS),0) * (IF(Q_DATA_IMPS > IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0)) * IMPS / Q_DATA_IMPS,(COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0) + COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))) + COALESCE(SUSPICIOUS_PASSED_IMPS,0) + COALESCE(SUSPICIOUS_FLAGGED_IMPS,0)) / IMPS,0))
						/ SUM(IF(COALESCE(MEDIA_TYPE_ID, 1) IN (2, 3, 112, 122, 132, 222, 232) AND VIDEO_FL = 1,COALESCE(PASSED_IMPS,0) + COALESCE(FLAGGED_IMPS,0),0)) AS 'PUBLICIS_VIDEO'
			FROM		analytics.AGG_AGENCY_QUALITY_V3 QUALITY									
			LEFT JOIN 	analytics.PUBLISHER PUB										
			ON 			QUALITY.PUBLISHER_ID = PUB.ID								
			LEFT JOIN 	analytics.MEDIA_PARTNER PARTNER										
			ON 			PUB.MEDIA_PARTNER_ID = PARTNER.ID								
			LEFT JOIN	analytics.PLACEMENT PLACEMENT										
			ON			QUALITY.PLACEMENT_ID = PLACEMENT.ID								
			LEFT JOIN	analytics.ADV_ENTITY ADV										
			ON			QUALITY.CAMPAIGN_ID = ADV.CAMPAIGN_ID								
			LEFT JOIN	analytics.team TEAM										
			ON			ADV.TEAM_ID = TEAM.ID								
			WHERE 		QUALITY.CAMPAIGN_ID IN (									
											   SELECT		CAMPAIGN_ID 	
											   FROM 		analytics.ADV_ENTITY 	
											   WHERE 		CAMPAIGN_ID <> 0 	
											   AND 			TEAM_ID IN ({{team_ids}})
											   )			
			AND 		DT >= 20171101									
			AND 		DT <= 20171130									
			-- Exclusion portion: Uncomment out to enable specific exclusions											
			-- AND			CAMPAIGN_NAME NOT IN ()								
			-- AND			PARTNER.NAME NOT IN ()								
			-- AND			PLACEMENT.NAME NOT IN ()								
			GROUP BY	1,2,3,4,5							
			HAVING		SUM(IMPS) > 50000
            ) VIEWABILITY
ON			BRAND_SAFETY.TEAM_ID = VIEWABILITY.TEAM_ID
AND			BRAND_SAFETY.TEAM_NAME = VIEWABILITY.TEAM_NAME
AND			BRAND_SAFETY.CAMPAIGN_NAME = VIEWABILITY.CAMPAIGN_NAME
AND			BRAND_SAFETY.PARTNER_NAME = VIEWABILITY.PARTNER_NAME
AND			BRAND_SAFETY.PLACEMENT_NAME = VIEWABILITY.PLACEMENT_NAME
AND			BRAND_SAFETY.DEVICE_TYPE = VIEWABILITY.DEVICE_TYPE
LEFT JOIN	(
			/******************************************************************************************
			Display Viewability Metrics (AGG_AGENCY_QUALITY_V3 Table)
			******************************************************************************************/
			SELECT		
						TEAM.ID AS 'TEAM_ID',
						LTRIM(RTRIM(TEAM.NAME)) AS 'TEAM_NAME',								
						'N/A' AS 'CAMPAIGN_NAME',								
						'N/A' AS 'PARTNER_NAME',								
						'N/A' AS 'PLACEMENT_NAME',
						'N/A' AS 'DEVICE_TYPE',
						/*** Metrics ***/
						-- Total Viewable Display Rate (Total Net Metrics)
						ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))))
						/ (ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0)))) + ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))))) AS 'TOTAL_VIEWABLE_DISPLAY_RATE'
			FROM		analytics.AGG_AGENCY_QUALITY_V3 QUALITY									
			LEFT JOIN 	analytics.PUBLISHER PUB										
			ON 			QUALITY.PUBLISHER_ID = PUB.ID								
			LEFT JOIN 	analytics.MEDIA_PARTNER PARTNER										
			ON 			PUB.MEDIA_PARTNER_ID = PARTNER.ID								
			LEFT JOIN	analytics.PLACEMENT PLACEMENT										
			ON			QUALITY.PLACEMENT_ID = PLACEMENT.ID								
			LEFT JOIN	analytics.ADV_ENTITY ADV										
			ON			QUALITY.CAMPAIGN_ID = ADV.CAMPAIGN_ID								
			LEFT JOIN	analytics.team TEAM										
			ON			ADV.TEAM_ID = TEAM.ID								
			WHERE 		QUALITY.CAMPAIGN_ID IN (									
											   SELECT		CAMPAIGN_ID 	
											   FROM 		analytics.ADV_ENTITY 	
											   WHERE 		CAMPAIGN_ID <> 0 	
											   AND 			TEAM_ID IN ({{team_ids}})
											   )			
			AND 		DT >= 20171101									
			AND 		DT <= 20171130	
			AND			MEDIA_TYPE_ID IN (111,121,131,221,231)							
			-- Exclusion portion: Uncomment out to enable specific exclusions											
			-- AND			CAMPAIGN_NAME NOT IN ()								
			-- AND			PARTNER.NAME NOT IN ()								
			-- AND			PLACEMENT.NAME NOT IN ()								
			GROUP BY	1,2,3,4,5							
			HAVING		SUM(IMPS) > 50000
            ) DISP_VIEWABILITY
ON			BRAND_SAFETY.TEAM_ID = DISP_VIEWABILITY.TEAM_ID
AND			BRAND_SAFETY.TEAM_NAME = DISP_VIEWABILITY.TEAM_NAME
AND			BRAND_SAFETY.CAMPAIGN_NAME = DISP_VIEWABILITY.CAMPAIGN_NAME
AND			BRAND_SAFETY.PARTNER_NAME = DISP_VIEWABILITY.PARTNER_NAME
AND			BRAND_SAFETY.PLACEMENT_NAME = DISP_VIEWABILITY.PLACEMENT_NAME
AND			BRAND_SAFETY.DEVICE_TYPE = DISP_VIEWABILITY.DEVICE_TYPE
LEFT JOIN	(
			/******************************************************************************************
			Video Viewability Metrics (AGG_AGENCY_QUALITY_V3 Table)
			******************************************************************************************/
			SELECT		TEAM.ID AS 'TEAM_ID',
						LTRIM(RTRIM(TEAM.NAME)) AS 'TEAM_NAME',								
						'N/A' AS 'CAMPAIGN_NAME',								
						'N/A' AS 'PARTNER_NAME',								
						'N/A' AS 'PLACEMENT_NAME',
						'N/A' AS 'DEVICE_TYPE',
						/*** Metrics ***/
						-- Total Viewable Video Rate (Total Net Metrics)
						ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))))
						/ (ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(IN_VIEW_PASSED_IMPS,0) + COALESCE(IN_VIEW_FLAGGED_IMPS,0)))) + ROUND(SUM(IF(Q_DATA_IMPS > IMPS, ((COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))/(Q_DATA_IMPS/IMPS)), COALESCE(NOT_IN_VIEW_PASSED_IMPS,0) + COALESCE(NOT_IN_VIEW_FLAGGED_IMPS,0))))) AS 'TOTAL_VIEWABLE_VIDEO_RATE'
			FROM		analytics.AGG_AGENCY_QUALITY_V3 QUALITY									
			LEFT JOIN 	analytics.PUBLISHER PUB										
			ON 			QUALITY.PUBLISHER_ID = PUB.ID								
			LEFT JOIN 	analytics.MEDIA_PARTNER PARTNER										
			ON 			PUB.MEDIA_PARTNER_ID = PARTNER.ID								
			LEFT JOIN	analytics.PLACEMENT PLACEMENT										
			ON			QUALITY.PLACEMENT_ID = PLACEMENT.ID								
			LEFT JOIN	analytics.ADV_ENTITY ADV										
			ON			QUALITY.CAMPAIGN_ID = ADV.CAMPAIGN_ID								
			LEFT JOIN	analytics.team TEAM										
			ON			ADV.TEAM_ID = TEAM.ID								
			WHERE 		QUALITY.CAMPAIGN_ID IN (									
											   SELECT		CAMPAIGN_ID 	
											   FROM 		analytics.ADV_ENTITY 	
											   WHERE 		CAMPAIGN_ID <> 0 	
											   AND 			TEAM_ID IN ({{team_ids}})
											   )			
			AND 		DT >= 20171101									
			AND 		DT <= 20171130	
			AND			MEDIA_TYPE_ID IN (112,122,132,222,232)			
			-- Exclusion portion: Uncomment out to enable specific exclusions											
			-- AND			CAMPAIGN_NAME NOT IN ()								
			-- AND			PARTNER.NAME NOT IN ()								
			-- AND			PLACEMENT.NAME NOT IN ()								
			GROUP BY	1,2,3,4,5							
			HAVING		SUM(IMPS) > 50000
            ) VID_VIEWABILITY
ON			BRAND_SAFETY.TEAM_ID = VID_VIEWABILITY.TEAM_ID
AND			BRAND_SAFETY.TEAM_NAME = VID_VIEWABILITY.TEAM_NAME
AND			BRAND_SAFETY.CAMPAIGN_NAME = VID_VIEWABILITY.CAMPAIGN_NAME
AND			BRAND_SAFETY.PARTNER_NAME = VID_VIEWABILITY.PARTNER_NAME
AND			BRAND_SAFETY.PLACEMENT_NAME = VID_VIEWABILITY.PLACEMENT_NAME
AND			BRAND_SAFETY.DEVICE_TYPE = VID_VIEWABILITY.DEVICE_TYPE
ORDER BY	8 DESC,1,2,3,4,5,6;