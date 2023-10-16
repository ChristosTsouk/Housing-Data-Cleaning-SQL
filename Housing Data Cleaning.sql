/*

Cleaning Data in SQL Queries

*/


Select *
From HousingProject..Housing

--------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format


Select SaleDateConverted, Cast(SaleDate as date)
From HousingProject..Housing


Update Housing
Set SaleDate = Cast(SaleDate as date)

-- If it doesn't Update properly

Alter table Housing
Add SaleDateConverted Date;

Update Housing
Set SaleDateConverted = Cast(SaleDate as date)


 --------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

Select *
From HousingProject..Housing
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingProject..Housing a
Join HousingProject..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From HousingProject..Housing a
Join HousingProject..Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

--Breaking Out Address Into Columns(Address,City,State)


Select PropertyAddress
From HousingProject..Housing
order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
From HousingProject..Housing



Alter table Housing
Add PropertySplitAddress Nvarchar(255);

Update Housing
Set PropertySplitAddress= SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter table Housing
Add PropertySplitCity Nvarchar(255);

Update Housing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))




Select OwnerAddress
From HousingProject..Housing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From HousingProject..Housing



Alter table Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From HousingProject..Housing



--------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant'

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From HousingProject.. Housing
Group By SoldAsVacant
order by 2



Select SoldAsVacant, 
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
END
From HousingProject.. Housing

Update Housing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
END





--------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE as (
Select *,
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
From HousingProject.. Housing
)

Select *
From RowNumCTE
where row_num> 1


---------------------------------------------------------------------------------------------------------
--Delete unused columns

Select *
From HousingProject..Housing


Alter table HousingProject..Housing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter table HousingProject..Housing
Drop column SaleDate