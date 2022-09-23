select*from
CovidPortofolioProject..NashvilleHousing$;

--Standarize date format
select SalesConvertedDate, convert(date, SaleDate) from
CovidPortofolioProject..NashvilleHousing$;

update CovidPortofolioProject..NashvilleHousing$
set SaleDate = convert(date, SaleDate)

Alter table NashvilleHousing$
add SalesConvertedDate date;

update CovidPortofolioProject..NashvilleHousing$
set SalesConvertedDate = convert(date, SaleDate)


--Populate the property address data
select * from
CovidPortofolioProject..NashvilleHousing$
--where PropertyAddress is null;
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress) 
from CovidPortofolioProject..NashvilleHousing$ a
join CovidPortofolioProject..NashvilleHousing$ b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from CovidPortofolioProject..NashvilleHousing$ a
join CovidPortofolioProject..NashvilleHousing$ b
     on a.ParcelID = b.ParcelID
	 and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--Breaking out address into individual collumn (address, city, state)
select PropertyAddress from
CovidPortofolioProject..NashvilleHousing$
--where PropertyAddress is null;
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address

from CovidPortofolioProject..NashvilleHousing$

Alter table NashvilleHousing$
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing$
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing$
add PropertySplitCity Nvarchar(255);

update NashvilleHousing$
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

select*from
CovidPortofolioProject..NashvilleHousing$


select OwnerAddress
from CovidPortofolioProject..NashvilleHousing$

select PARSENAME(replace(OwnerAddress, ',','.') ,1)
,PARSENAME(replace(OwnerAddress, ',','.') ,2)
,PARSENAME(replace(OwnerAddress, ',','.') ,3)
from CovidPortofolioProject..NashvilleHousing$

Alter table NashvilleHousing$
add OwnerSplitState Nvarchar(255)

update NashvilleHousing$
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.') ,1)

Alter table NashvilleHousing$
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing$
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.') ,2)

Alter table NashvilleHousing$
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing$
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.') ,3)

select*from
CovidPortofolioProject..NashvilleHousing$

--Change Y to Yes and N to No in 'SolidAsVacant' Field
select distinct(SoldAsVacant), count(SoldAsVacant)
from CovidPortofolioProject..NashvilleHousing$
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from CovidPortofolioProject..NashvilleHousing$

update NashvilleHousing$
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

--Remove Duplicates
with RowNumCTE as(
select*,
      ROW_NUMBER() over(
	  partition by ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				      UniqueID
					  )row_num
from CovidPortofolioProject..NashvilleHousing$
--order by ParcelID
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress


--Delete Unused Column
select*from
CovidPortofolioProject..NashvilleHousing$;

alter table CovidPortofolioProject..NashvilleHousing$
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table CovidPortofolioProject..NashvilleHousing$
drop column SaleDate