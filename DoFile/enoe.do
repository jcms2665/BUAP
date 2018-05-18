capture program drop enoe
program define enoe
version 14
clear all
capture confirm file "RESULTADOS.dta"
if _rc!=0{
capture confirm file "`1'.dta"
if _rc==0{
use `1', clear
capture confirm variable `2'
if _rc==0 {
clear
local myfilelist : dir "." files "*.dta"
local i=1
foreach filename of local myfilelist {
use "`filename'"
confirm existence variable k
if _rc {
drop k
}
gen k=cd_a+ent+con+v_sel+n_hog+h_mud+n_ren
keep if (n_ent=="`i'" & r_def=="00" & (c_res=="1" | c_res=="3"))
keep k `2' n_ent per
rename n_ent n_ent_`i'
rename per per_`i'
rename `2' `2'_`i'
sort k
save "`i'test"
clear
local ++i
}
use `1', clear
confirm existence variable k
if _rc {
drop k
}
gen k=cd_a+ent+con+v_sel+n_hog+h_mud+n_ren
sort k
local myfilelist : dir "." files "*test*.dta"
foreach filename of local myfilelist {
merge 1:1 k using "`filename'", noreport
drop if _merge==2
drop _merge
}
drop `2'_1 n_ent_1 per_1
local list : dir . files "*test*.dta"
foreach f of local list {
erase "`f'"
}
save "`1'_secuencias.dta", replace
clear
display " "
display "Se ha creado el archivo `1'_secuencias"
display "{txt}{hline 62}
}
else {
display as err "La variable `2' no existe, favor de verificar"
display "{txt}{hline 62}
}
}
else {
display as err "El archivo `1'.dta no existe, favor de verificar"
display "{txt}{hline 62}
}
}
else {
display as err "El archivo resultados.dta ya existe, renombrar/borrar para ejecutar el programa"
display "{txt}{hline 62}
}
end

