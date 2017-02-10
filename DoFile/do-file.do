

**********************************
*  MUESTRAS COMPLEJAS CON STATA  *
*				BUAP			 *
**********************************




*  	Contenido  

*0. Cargar y filtrar la base
*1. Definir el esquema de muestreo
	*1.1. Totales	
	*1.2. Promedio
	*1.3. Proporción
*2. Subpoblaciones (Problemas)
*3. Pruebas de hipótesis
	*3.1.  Estimadores 215
	*3.1.  Estimadores 214
*4. Modelos de regresión
	*4.1. Muestro Aleatorio Simple
	*4.2. Muestro Estratificado y por Conglomerados
	*4.3. Comparación entre modelos

	
	
	
	
*0. Cargar y filtrar la base

	/* Antes de iniciar con el análisis, se debe de filtrar a los casos válidos que
	   son aquellos residentes habituales con entrevista completa y dentro del rango
	   de edad */

	   
	use "C:\Users\JC\Desktop\BUAP\sdemt215.dta", clear	
	
	gen filtro=((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=98))
	tab filtro [fw=fac], m


*1. Definir el esquema de muestreo

	/* Stata tiene varios métodos para hacer calcular los errores de muestreo, 
	   pero en este caso se usará la "Linealización por Series de Taylor". */

	svyset upm [pw=fac], strata(est_d) vce(linearized)

	*1.1. Totales	
	
		svy, subpop(filtro): tab clase2, format(%11.3g) count se cv ci level(90)

	*1.2. Promedio

		/* Para el caso particular de la ENOE se genera otro filtro con 98
		   Edad no especificada para mayores de 12 años y más */

		gen int f2=((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=97))
		svy, subpop (f2): mean eda if (clase1==1), level(90)
		estat cv

	*1.3. Proporción

		svy, subpop (filtro):prop clase1, level(90)
		estat cv


*2. Subpoblaciones (Problemas)
	
	/* Cuando se analizan poblaciones muy pequeñas se pueden presentar problemas.
	   En particular al momento de calcular el coeficiente de variación
	   aparece la siguiente leyenda:
	   Note: missing standard errors because of stratum with single sampling unit.*/


	gen ti=((c_res==1 | c_res==3) & r_def==0 & (eda>=12 & eda<15) & clase2==1)
	tab ti [fw=fac]
	svy, subpop (ti): tab rama if (sex==2 & eda==14), format(%11.3g) count se cv ci level(90)

	/* La solución es crear "pseudoestratos". Para ello, Stata tiene varios métidos
	   como: missing, certainty, scaled, o centered  */
	
	svyset, clear
	svyset upm [pw=fac], strata(est_d) vce(linearized) single(sca)
	svy, subpop (ti): tab rama if (sex==2 & eda==14), format(%11.3g) count se cv ci level(90)


*3. Pruebas de hipótesis

	/* "..con frecuencia se tiende a analizar los datos de una encuesta por muestreo 
	   probabilístico como si fueran los datos provenientes de un censo. De ahí que 
	   muchas veces se asume la diferencia en el valor de un indicador, de un trimestre con 
	   respecto a otro, como si fuera una diferencia real cuando no necesariamente es así.."*/
	   
	/* http://www.beta.inegi.org.mx/contenidos/proyectos/enchogares/regulares/enoe/doc/enoe_significancia.pdf */

	*3.1.  Estimadores 215
		svyset, clear
		svyset upm [pw=peso], strata(est_d) vce(linearized) single(sca)
		svy, subpop(filtro): tab clase2, format(%11.3g) count se cv ci level(90)

	*3.1.  Estimadores 214
		svyset, clear
		use "C:\Users\JC\Desktop\BUAP\sdemt214.dta", clear
		svyset upm [pw=peso], strata(est_d) vce(linearized) single(sca)
		gen filtro=((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=98))
		svy, subpop(filtro): tab clase2, format(%11.3g) count se cv ci level(90)
		

*4. Modelos de regresión
	
	svyset, clear
	use "C:\Users\JC\Desktop\BUAP\sdemt215.dta", clear
	svyset upm [pw=fac], strata(est_d) vce(linearized) single(sca)
	
	/* Variables ordinales*/
	
	gen int ocupado=(clase2==1)
	gen int sexo = round(sex)
	gen int nivel = round(niv_ins)
	gen int econ = round(e_con)
	gen int edad7 = round(eda7c)

	
*4.1. Muestro Aleatorio Simple
	
	logit ocupado anios_esc i.edad7 i.sexo i.econ    if ((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=97))
	logit, or
	estimates store modelo_1

*4.2. Muestro Estratificado y por Conglomerados

	gen f3=((c_res==1 | c_res==3) & r_def==0 & (eda>=15 & eda<=98) & (eda>=15 & eda<=97))
	svy, subpop(f3): logit ocupado anios_esc i.edad7 i.sexo i.econ 
	logit, or
	estimates store modelo_2
	
*4.3. Comparación entre modelos
	
	estimates table modelo_1 modelo_2,  b(%6.2f) star(0.05 0.01 .001) eform
