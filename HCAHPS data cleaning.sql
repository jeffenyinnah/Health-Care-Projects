USE ProjectPortfolio;


With HospitalBedCTE as 
(
 SELECT [Provider CCN], 
	
		Case 
		when len(Cast([Provider CCN] as nvarchar)) < 6 then RIGHT('0' + Cast([Provider CCN] as nvarchar),6)
		else Cast([Provider CCN] as nvarchar) end as ProviderCCN,
	[Hospital Name],
	CAST([Fiscal Year Begin Date] as date) as newFiscalYearBeginDate,
	CAST([Fiscal Year End Date] as date) as newFiscalYearEndDate,
	number_of_beds,
	ROW_NUMBER() over (Partition by [Provider CCN] order by CAST([Fiscal Year End Date] as date) desc) as RowNumber
 FROM Hospital_Beds
 )

select
	CASE 
		WHEN len(CAST([Facility ID] as nvarchar)) < 6 then RIGHT('0' + CAST([Facility ID] as nvarchar), 6) 
		else CAST([Facility ID] as nvarchar) end as facilityID,
	cast([Start Date] as date) as convertedStartDate,
	cast([End Date] as date) as convertedEndDate,
	*,
	HB.newFiscalYearBeginDate as BedStartReportPeriod,
	HB.newFiscalYearEndDate as BedEndReportPeriod

into tableau_file

from [dbo].[HCAHPS_data] as HD
left join HospitalBedCTE as HB
	on CASE 
		WHEN len(CAST([Facility ID] as nvarchar)) < 6 then RIGHT('0' + CAST([Facility ID] as nvarchar), 6) 
		else CAST([Facility ID] as nvarchar) end  = HB.ProviderCCN
and HB.RowNumber = 1

