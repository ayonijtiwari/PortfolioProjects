/*

Cleaning Data in SQL Queries

*/

select *
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date Format

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing


--Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

----There are some repititions of ParcelID----
----Each ParcelID corresponds to PropertyAddress----

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL 

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


--Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID 

select 
substring (PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Address,
substring (PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


select *
from PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)


alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)


alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)


select *
from PortfolioProject.dbo.NashvilleHousing


--Change Y and N to Yes and No respectively in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 	case when SoldAsVacant = 'Y' then 'Yes'
						 when SoldAsVacant = 'N' then 'No'
						 else SoldAsVacant
						 end



--Remove Duplicates

with RowNumCTE as (
    select *, 
           row_number() over (
               partition by ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               order by UniqueID
           ) as row_num
    from PortfolioProject.dbo.NashvilleHousing
)
delete
from RowNumCTE
where row_num>1


with RowNumCTE as (
    select *, 
           row_number() over (
               partition by ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               order by UniqueID
           ) as row_num
    from PortfolioProject.dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num>1


--Delete Unused Columns

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, PropertyAddress, SaleDate

