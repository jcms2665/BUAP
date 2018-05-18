**********************************
*      FACTORES DE EXPANSIÓN     *
*				BUAP			 *
**********************************


*0. Cargar la base de datos

use  "C:\Users\jmartinez\Google Drive\SIMO\Esc\ANA\ENOE\enoe_15ymas_2009\2009trim2\marco_muestral.dta", replace

*1. Generar las probabilidades de inserción de la primera etapa

contract ent upm, freq(viviendas)
sort ent
by ent: generate double pi1=10/_N
label var pi1 "Probabilidad de inserción 1"

*2. Hacer la selección de las UPM

levelsof ent, local(TRACTlev)
foreach i of local TRACTlev{
quietly sample 10 if ent==`i', count
}
sort ent

cd "C:\Users\jmartinez\Google Drive\SIMO\Esc\ANA\ENOE\enoe_15ymas_2009\2009trim2"
save upm_seleccionadas, replace

*3. Generar las probabilidades de inserción de la segunda etapa

use  "C:\Users\jmartinez\Google Drive\SIMO\Esc\ANA\ENOE\enoe_15ymas_2009\2009trim2\marco_muestral.dta", replace
merge m:1 ent upm using upm_seleccionadas
keep if _merge==3
drop _merge
sort upm
by upm: generate double pi2=5/_N
label var pi2 "Stage 2 sampling probabilities"
levelsof upm, local(TRACTlev)
foreach i of local TRACTlev{
quietly sample 5 if upm==`i', count
}


*4. Cálculo de los factores de expansión

gen double fac=1/(pi1*pi2)
export delimited using "C:\Users\jmartinez\Google Drive\SIMO\Esc\ANA\ENOE\enoe_15ymas_2009\2009trim2\resultaods.csv", replace
