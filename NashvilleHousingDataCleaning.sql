
-- DATA CLEANING USING SQL

select * from PortfolioProject.dbo.NashvilleHousing

select SaleDateConverted, CONVERT(date,SaleDate) as SaleDateUpdated
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing 
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted date;

Update PortfolioProject..NashvilleHousing 
SET SaleDateConverted = CONVERT(date,SaleDate)

-----------------------------------------------------------------------------
-- Property Address 

select PropertyAddress
from PortfolioProject..NashvilleHousing
where PropertyAddress is null


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null

Update a 
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[uniqueID] <> b.[uniqueID]
where a.PropertyAddress is null


--------------------------------------------------------
--Address into Address, City columns

select PropertyAddress
from PortfolioProject..NashvilleHousing


SELECT 
SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as State
from PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertyAddressSplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET PropertyAddressSplit = SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertyCitySplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET PropertyCitySplit = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing

-----------------------------------------------------
-- Parse Name

select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
from PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET OwnerAddressSplit = PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerCitySplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET OwnerCitySplit = PARSENAME(Replace(OwnerAddress,',','.'),2)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerStateSplit Nvarchar(255);

Update PortfolioProject..NashvilleHousing 
SET OwnerStateSplit = PARSENAME(Replace(OwnerAddress,',','.'),1)


--------------------------------------------------------------------------

-- Change Y and N to Yes and No

select Distinct(soldAsVacant), Count(soldAsVacant)
from PortfolioProject..NashvilleHousing 
group by soldAsvacant
order by 2


select soldAsVacant
, CASE when soldAsVacant ='Y' then 'Yes'
	   when soldAsVacant ='N' then 'No'
	   ELSE soldAsVacant
	   END
from PortfolioProject..NashvilleHousing 

Update PortfolioProject..NashvilleHousing
SET soldAsVacant = CASE when soldAsVacant ='Y' then 'Yes'
	   when soldAsVacant ='N' then 'No'
	   ELSE soldAsVacant
	   END

--------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 uniqueID
				 ) row_num
from PortfolioProject..NashvilleHousing )
--order by ParcelID

DELETE from RowNumCTE where row_num > 1

------------------------------------------------------

-- DELETE unused Columns
Select * 
from PortfolioProject..NashvilleHousing

--delete ownerAddress since its split 

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress