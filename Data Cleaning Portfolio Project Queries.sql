/*

Cleaning Data in SQL Queries

*/

select * from nashvillehousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate, CONVERT(date,SaleDate) from nashvillehousing

update nashvillehousing	
set SaleDate = CONVERT(date,SaleDate)

-- To check if date is updated

select * from nashvillehousing

-- it not worked so we can do another method to add just date column in table 

alter table nashvillehousing
add SaleDateConverted date;

update nashvillehousing	
set SaleDateConverted = CONVERT(date,SaleDate);

-- To check if date is updated

select * from nashvillehousing

-- or

select SaleDateConverted, CONVERT(date,SaleDate) from nashvillehousing

--DONE


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
select * from nashvillehousing
where PropertyAddress is null



select e1.ParcelID, e1.PropertyAddress, e2.ParcelID, e2.PropertyAddress, ISNULL(e1.PropertyAddress,e2.PropertyAddress)
from nashvillehousing e1
join nashvillehousing e2
on e1.ParcelID = e2.ParcelID
and e1.[UniqueID ] != e2.[UniqueID ]
where e1.PropertyAddress is null


update e1
set PropertyAddress = ISNULL(e1.PropertyAddress,e2.PropertyAddress)
from nashvillehousing e1
join nashvillehousing e2
on e1.ParcelID = e2.ParcelID
and e1.[UniqueID ] != e2.[UniqueID ]
where e1.PropertyAddress is null

-- TO CHECK ALL PROPERTY ADDRESS IS FILLED

select * from nashvillehousing
where PropertyAddress is null

-- IT WILL GIVE BLANK TABLE

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select * from nashvillehousing


select SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress)) as city
from nashvillehousing


alter table nashvillehousing
add Property_Split_Address varchar(255);

update nashvillehousing	
set Property_Split_Address = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress)-1);



alter table nashvillehousing
add Property_Split_City varchar(255);
update nashvillehousing	
set Property_Split_City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,len(PropertyAddress));

select PropertyAddress,Property_Split_Address,Property_Split_City from nashvillehousing

--------------------------------------------------------------------------------------------------------------------------
 -- Breaking out Address into Individual Columns (Address, City, State) for owner

	select PARSENAME(replace(OwnerAddress,',','.'),3),
	PARSENAME(replace(OwnerAddress,',','.'),2),
	PARSENAME(replace(OwnerAddress,',','.'),1)
	from nashvillehousing


		alter table nashvillehousing
		add Owner_Split_Address varchar(255);
		alter table nashvillehousing
		add Owner_Split_City varchar(255);
		alter table nashvillehousing
		add Owner_Split_State varchar(255);
		update nashvillehousing	
		set Owner_Split_Address = PARSENAME(replace(OwnerAddress,',','.'),3);
		update nashvillehousing	
		set Owner_Split_City = PARSENAME(replace(OwnerAddress,',','.'),2);
		update nashvillehousing	
		set Owner_Split_State = PARSENAME(replace(OwnerAddress,',','.'),1);




		select * from nashvillehousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from nashvillehousing
group by SoldAsVacant
order by count(SoldAsVacant)



select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end
from nashvillehousing

update nashvillehousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant
end



select * from nashvillehousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
    SELECT *,  
           ROW_NUMBER() OVER (PARTITION BY ParcelID,  
                                          PropertyAddress,  
                                          SalePrice,  
                                          LegalReference  
                               ORDER BY UniqueID) AS rownum  
    FROM nashvillehousing  
)  
SELECT * FROM RowNumCTE
where rownum>1;


WITH RowNumCTE AS (
    SELECT *,  
           ROW_NUMBER() OVER (PARTITION BY ParcelID,  
                                          PropertyAddress,  
                                          SalePrice,  
                                          LegalReference  
                               ORDER BY UniqueID) AS rownum  
    FROM nashvillehousing  
)  
delete 
FROM RowNumCTE
where rownum>1;




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns




alter table nashvillehousing
drop column PropertyAddress, OwnerAddress,TaxDistrict


alter table nashvillehousing
drop column SaleDate


select * from nashvillehousing












-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















