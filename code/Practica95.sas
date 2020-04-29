/* ----------------------------------------
Código exportado desde SAS Enterprise Guide
FECHA: miércoles, 29 de abril de 2020     HORA: 13:06:50
PROYECTO: Proyecto
RUTA DEL PROYECTO: 
---------------------------------------- */

/* ---------------------------------- */
/* MACRO: enterpriseguide             */
/* PURPOSE: define a macro variable   */
/*   that contains the file system    */
/*   path of the WORK library on the  */
/*   server.  Note that different     */
/*   logic is needed depending on the */
/*   server type.                     */
/* ---------------------------------- */
%macro enterpriseguide;
%global sasworklocation;
%local tempdsn unique_dsn path;

%if &sysscp=OS %then %do; /* MVS Server */
	%if %sysfunc(getoption(filesystem))=MVS %then %do;
        /* By default, physical file name will be considered a classic MVS data set. */
	    /* Construct dsn that will be unique for each concurrent session under a particular account: */
		filename egtemp '&egtemp' disp=(new,delete); /* create a temporary data set */
 		%let tempdsn=%sysfunc(pathname(egtemp)); /* get dsn */
		filename egtemp clear; /* get rid of data set - we only wanted its name */
		%let unique_dsn=".EGTEMP.%substr(&tempdsn, 1, 16).PDSE"; 
		filename egtmpdir &unique_dsn
			disp=(new,delete,delete) space=(cyl,(5,5,50))
			dsorg=po dsntype=library recfm=vb
			lrecl=8000 blksize=8004 ;
		options fileext=ignore ;
	%end; 
 	%else %do; 
        /* 
		By default, physical file name will be considered an HFS 
		(hierarchical file system) file. 
		*/
		%if "%sysfunc(getoption(filetempdir))"="" %then %do;
			filename egtmpdir '/tmp';
		%end;
		%else %do;
			filename egtmpdir "%sysfunc(getoption(filetempdir))";
		%end;
	%end; 
	%let path=%sysfunc(pathname(egtmpdir));
    %let sasworklocation=%sysfunc(quote(&path));  
%end; /* MVS Server */
%else %do;
	%let sasworklocation = "%sysfunc(getoption(work))/";
%end;
%if &sysscp=VMS_AXP %then %do; /* Alpha VMS server */
	%let sasworklocation = "%sysfunc(getoption(work))";                         
%end;
%if &sysscp=CMS %then %do; 
	%let path = %sysfunc(getoption(work));                         
	%let sasworklocation = "%substr(&path, %index(&path,%str( )))";
%end;
%mend enterpriseguide;

%enterpriseguide


/* Conditionally delete set of tables or views, if they exists          */
/* If the member does not exist, then no action is performed   */
%macro _eg_conditional_dropds /parmbuff;
	
   	%local num;
   	%local stepneeded;
   	%local stepstarted;
   	%local dsname;
	%local name;

   	%let num=1;
	/* flags to determine whether a PROC SQL step is needed */
	/* or even started yet                                  */
	%let stepneeded=0;
	%let stepstarted=0;
   	%let dsname= %qscan(&syspbuff,&num,',()');
	%do %while(&dsname ne);	
		%let name = %sysfunc(left(&dsname));
		%if %qsysfunc(exist(&name)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;

			%end;
				drop table &name;
		%end;

		%if %sysfunc(exist(&name,view)) %then %do;
			%let stepneeded=1;
			%if (&stepstarted eq 0) %then %do;
				proc sql;
				%let stepstarted=1;
			%end;
				drop view &name;
		%end;
		%let num=%eval(&num+1);
      	%let dsname=%qscan(&syspbuff,&num,',()');
	%end;
	%if &stepstarted %then %do;
		quit;
	%end;
%mend _eg_conditional_dropds;


/* save the current settings of XPIXELS and YPIXELS */
/* so that they can be restored later               */
%macro _sas_pushchartsize(new_xsize, new_ysize);
	%global _savedxpixels _savedypixels;
	options nonotes;
	proc sql noprint;
	select setting into :_savedxpixels
	from sashelp.vgopt
	where optname eq "XPIXELS";
	select setting into :_savedypixels
	from sashelp.vgopt
	where optname eq "YPIXELS";
	quit;
	options notes;
	GOPTIONS XPIXELS=&new_xsize YPIXELS=&new_ysize;
%mend _sas_pushchartsize;

/* restore the previous values for XPIXELS and YPIXELS */
%macro _sas_popchartsize;
	%if %symexist(_savedxpixels) %then %do;
		GOPTIONS XPIXELS=&_savedxpixels YPIXELS=&_savedypixels;
		%symdel _savedxpixels / nowarn;
		%symdel _savedypixels / nowarn;
	%end;
%mend _sas_popchartsize;


ODS PROCTITLE;
OPTIONS DEV=PNG;
GOPTIONS XPIXELS=0 YPIXELS=0;
FILENAME EGSRX TEMP;
ODS tagsets.sasreport13(ID=EGSRX) FILE=EGSRX
    STYLE=HtmlBlue
    STYLESHEET=(URL="file:///C:/Program%20Files%20(x86)/SASHome/x86/SASEnterpriseGuide/7.1/Styles/HtmlBlue.css")
    NOGTITLE
    NOGFOOTNOTE
    GPATH=&sasworklocation
    ENCODING=UTF8
    options(rolap="on")
;

/*   INICIO DEL NODO: Practica95   */
%LET _CLIENTTASKLABEL='Practica95';
%LET _CLIENTPROCESSFLOWNAME='Flujo del proceso';
%LET _CLIENTPROJECTPATH='';
%LET _CLIENTPROJECTPATHHOST='';
%LET _CLIENTPROJECTNAME='';
%LET _SASPROGRAMFILE='/home/u44690176/my_courses/Mariceli/mariceli0/code/Practica95.sas';
%LET _SASPROGRAMFILEHOST='odaws01-euw1.oda.sas.com';

GOPTIONS ACCESSIBLE;
*Libreria de acceso a la carpeta Data;
libname lib_in  "/home/u44690176/my_courses/Mariceli/mariceli0/data";


*Libreria de acceso a la carpeta output, donde almacenaremos los resultados;

libname lib_out  "/home/u44690176/my_courses/Mariceli/mariceli0/output";

/*dataset*/
data gasolina95;
  set lib_in.gasoline_in_spain;
run;

/*Rdo: 72.113 observaciones y 25 variables*/


/*Análisis de missings de mi variable target*/

proc means data=gasolina95 nmiss;
  var Precio_gasolina_95;
run;


/*Missing: 2818*/
/*Los elimino, no puedo tener missing en mi variable target*/

data gasolina95;
  set gasolina95;
    if Precio_gasolina_95=. then delete;
run;



/*Rdo: 69.295 observaciones y 25 variables*/

/*************************************************/

/*** Analisis de duplicidades ******/

/*Establezco como clave primaria: fecha Longitud Latitud*/
/*No debería haber más de un registro para una misma ubicación el mismo dia*/
/*Comprobamos que no existan duplicados en base a la primary key*/

proc sort data=gasolina95 nodupkey dupout=duplicados;
  by fecha Longitud Latitud;
run;

/*Rdo: 69.204 observaciones, duplicados: 91*/

/******* Analisis de los estadísticos básicos *****/

proc means data=gasolina95;
  var Precio_gasolina_95;
run;

/*Observo valores muy extraños con un máximo altísimo*/

data gasolina95;
  set gasolina95;
run;

/*Me ayudo de las opciones de Filtro y Orden y Clasificacion para ver donde está el salto y que se debe
a que parte de la tabla está como desplazada hacia la derecha haciendo que en el precio de la gasolina de 95
nos aparezcan datos de la latitud*/

/*Elimino esos valores erroneos*/

data gasolina95;
  set gasolina95;
    if Precio_gasolina_95>20000 then delete;
run;

/*Resultado: 58973 observaciones y 25 variables*/

proc means data=gasolina95;
  var Precio_gasolina_95;
run;

/*Ahora si tengo valores más normales*/

/*Realizo un análisis más proforndo de outliers, missings e incongruencias*/

proc univariate data=gasolina95;
   var Precio_gasolina_95;
run;


/******************* ANALISIS DE VARIABLES CATEGORICAS **************/



/*Longitud, Latitud y Codigo postal no nos son utiles ya que tenemos el Municipio y la Provincia por lo que es info duplicada
/*están fuertemente correladas, el código postal representan la misma infom que el municipio y provincia*/
/*eliminamos las 3 variables del estudio*/

data gasolina95;
  set gasolina95;
  drop longitud latitud codigo_postal;
run;


/*Analisis de la variable: Fecha*/

proc freq data=gasolina95;
  tables Fecha;
run;

/*Analisis de la variable Provincia*/

proc freq data=gasolina95;
  tables Provincia;
run;
/*Nada que destacar*/

/*Analisis de la variable Municipio*/
proc freq data=gasolina95;
  tables Municipio;
run;

/*Nada que destacar*/

/*Analisis de la variable Localidad*/
proc freq data=gasolina95;
  tables Localidad;
run;

/*Como me piden el precio a nivel de provincia voy a eliminar para el modelo Municipio y Localidad*/
data gasolina95;
  set gasolina95;
  drop Municipio Localidad;
run;


/*Analisis de la variable Direccion*/

/*Con la dirección ocurre como con las coordenadas, podríamos elimnarla pero antes vamos a extraer información util
sobre la ubicación ya que el precio puede depender de si la gasolinera está en una calle, autovía, aeropuerto
Creamos por tanto una variable zona que contencrá la ubicación que voy a extraer desde la dirección

/*También puedo eliminar dirección pero vamos a extraer el tipo de via que nos puede interar para el precio*/

data lib_in.gasolina1;
  set gasolina95;
run;

data gasolina95;
  set lib_in.gasolina1;
run;

data gasolina95;
  set gasolina95;
  format zona $50.;
  if findw(upcase(direccion), "AEROPUERTO")OR findw(upcase(direccion), "AÉROPUERTO") then zona="AEROPUERTO";
    else if findw(upcase(direccion), "PLAZA") OR findw(upcase(direccion), "PZA.") then zona="PLAZA";
	else if findw(upcase(direccion), "AUTOVIA")OR findw(upcase(direccion), "CR A")OR findw(upcase(direccion), "AUTOVÍA")
           OR findw(upcase(direccion), "AU") then zona="AUTOVIA";
	else if findw(upcase(direccion), "CARRETERA") OR findw(upcase(direccion), "KM") OR findw(upcase(direccion), "CARRER")
           OR findw(upcase(direccion), "CR")OR findw(upcase(direccion), "CTRA")OR findw(upcase(direccion), "CTRA.")OR findw(upcase(direccion), "CRTA.")
           OR findw(upcase(direccion), "CRA.")OR findw(upcase(direccion), "P.K.") OR findw(upcase(direccion), "PK")OR findw(upcase(direccion), "CARRERA")then zona="CARRETERA";
    else if findw(upcase(direccion), "CALLE") OR findw(upcase(direccion), "RUA") OR findw(upcase(direccion), "BARRIO")
           OR findw(upcase(direccion), "CL") OR findw(upcase(direccion), "C/")OR findw(upcase(direccion), "VIA")
           OR findw(upcase(direccion), "VÍA")OR findw(upcase(direccion), "LUGAR") OR findw(upcase(direccion), "URBANIZACIÓN")
           OR findw(upcase(direccion), "BARRIADA")OR findw(upcase(direccion), "URB.")OR findw(upcase(direccion), "CALZADA")
           OR findw(upcase(direccion), "RAMBLA")OR findw(upcase(direccion), "CUESTA")OR findw(upcase(direccion), "PASAJE")
           OR findw(upcase(direccion), "PASSATGE")OR findw(upcase(direccion), "UR")OR findw(upcase(direccion), "BDA.")
           OR findw(upcase(direccion), "PARTIDA")OR findw(upcase(direccion), "BULEVAR")OR findw(upcase(direccion), "BDA.")
           OR findw(upcase(direccion), "CALLEJA")then zona="CALLE";
	else if findw(upcase(direccion), "AVENIDA") OR findw(upcase(direccion), "AVD") OR findw(upcase(direccion), "AVINGUDA") 
           OR findw(upcase(direccion), "AV.") OR findw(upcase(direccion), "AVD.") OR findw(upcase(direccion), "AVDA.")
           OR findw(upcase(direccion), "AV")OR findw(upcase(direccion), "AVDA")then zona="AVENIDA";
    else if findw(upcase(direccion), "POLIGONO") OR findw(upcase(direccion), "P.I.")OR findw(upcase(direccion), "POLG")
           OR findw(upcase(direccion), "POLÍGONO")OR findw(upcase(direccion), "INDUSTRIAL") OR findw(upcase(direccion), "POL.IND.")
           OR findw(upcase(direccion), "IND.")OR findw(upcase(direccion), "POLIG.")OR findw(upcase(direccion), "POL.")
           OR findw(upcase(direccion), "PGNO.")OR findw(upcase(direccion), "PG")then zona="POLIGONO";
	else if findw(upcase(direccion), "PASEO")OR findw(upcase(direccion), "PASSEIG") then zona="PASEO";
	else if findw(upcase(direccion), "CAMINO")OR findw(upcase(direccion), "CAMI")OR findw(upcase(direccion), "VEREDA")
           OR findw(upcase(direccion), "PARAJE")OR findw(upcase(direccion), "CAÑADA")OR findw(upcase(direccion), "PARATGE") then zona="CAMINO";
	else if findw(upcase(direccion), "ROTONDA") OR findw(upcase(direccion), "GLORIETA") then zona="ROTONDA";
    else if findw(upcase(direccion), "MUELLE") then zona="MUELLE";
	else if findw(upcase(direccion), "ESTACION") then zona="ESTACION";
	else if findw(upcase(direccion), "TRAVESIA") OR findw(upcase(direccion), "TRAVESÍA")OR findw(upcase(direccion), "TRAVESSERA")then zona="TRAVESIA";
	else if findw(upcase(direccion), "RONDA") OR findw(upcase(direccion), "RDA.")OR findw(upcase(direccion), "RD") then zona="RONDA";
	else if findw(upcase(direccion), "CRUCE") then zona="CRUCE";
	else if findw(upcase(direccion), "COMERCIAL") then zona="CENTRO COMERCIAL";
	else if findw(upcase(direccion), "PARQUE") OR findw(upcase(direccion), "PARC")then zona="PARQUE";
	else if findw(upcase(direccion), "AP")OR findw(upcase(direccion), "AT") then zona="AUTOPISTA";
	else if findw(upcase(direccion), "PARQUE EMPRESARIAL") then zona="PARQUE EMPRESARIAL";
    /*else zona='missings';*/
	else zona="CALLE";
	drop direccion;    
run;



proc freq data=gasolina95;
  tables zona;
run;

/*Analisis de la variable Margen*/
proc freq data=gasolina95;
  tables Margen;
run;

/*No hay missings ni outliers. No está balanceada, hay más proporción en el margen derecho*/

/*Analisis de la variable Rotulo*/

proc freq data=gasolina95;
  tables Rotulo;
run;

data gasolina95;
  set gasolina95;
  format rotulo_limpio $60.;
  rotulo_limpio = translate (rotulo, ' ', '"');

run;


data gasolina95;
  set gasolina95;
 format cartel $50.;
  if findw(upcase(rotulo_limpio), "CEPSA") then cartel="CEPSA";
    else if findw(upcase(rotulo_limpio), "BP") OR findw(upcase(rotulo_limpio), "B.P.") then cartel="BP";
	else if findw(upcase(rotulo_limpio), "SHELL") then cartel="SHELL";
	else if findw(upcase(rotulo_limpio), "DISA") then cartel="DISA";
	else if findw(upcase(rotulo_limpio), "REPSOL") then cartel="REPSOL";
	else if findw(upcase(rotulo_limpio), "CEPSA") then cartel="CEPSA";
	else if findw(upcase(rotulo_limpio), "GALP") then cartel="GALP";
	else if findw(upcase(rotulo_limpio), "CARREFOUR") OR findw(upcase(rotulo_limpio), "CARRREFOUR")then cartel="CARREFOUR";
	else if findw(upcase(rotulo_limpio), "ALCAMPO") then cartel="ALCAMPO";
	else if findw(upcase(rotulo_limpio), "AGLA") then cartel="AGLA";
	else if findw(upcase(rotulo_limpio), "ALAMEDA") then cartel="ALAMEDA";
	else if findw(upcase(rotulo_limpio), "AN ENERGETICOS") then cartel="AN ENERGETICOS";
	else if findw(upcase(rotulo_limpio), "ANDAMUR") then cartel="ANDAMUR";
	else if findw(upcase(rotulo_limpio), "ARENTO") then cartel="ARENTO";
	else if findw(upcase(rotulo_limpio), "ASC") then cartel="ASC";
	else if findw(upcase(rotulo_limpio), "AVANZA") then cartel="AVANZA";
	else if findw(upcase(rotulo_limpio), "AVIA") then cartel="AVIA";
	else if findw(upcase(rotulo_limpio), "BDMED") then cartel="BDMED";
	else if findw(upcase(rotulo_limpio), "BENZINA") then cartel="BENZINA";
	else if findw(upcase(rotulo_limpio), "BENZINERA") then cartel="BENZINERA";
	else if findw(upcase(rotulo_limpio), "BEROIL") then cartel="BEROIL";
	else if findw(upcase(rotulo_limpio), "BIOMAR") then cartel="BIOMAR";
	else if findw(upcase(rotulo_limpio), "CAMPSA") then cartel="CAMPSA";
	else if findw(upcase(rotulo_limpio), "CANARY") then cartel="CANAY";
	else if findw(upcase(rotulo_limpio), "CLC") then cartel="CLC";
	else if findw(upcase(rotulo_limpio), "DST") then cartel="DST";
	else if findw(upcase(rotulo_limpio), "E.LECLERC") OR findw(upcase(rotulo_limpio), "E-LECLERC")OR findw(upcase(rotulo_limpio), "LECLERC") then cartel="LECLERC";
	else if findw(upcase(rotulo_limpio), "ECOSUMINISTROS") then cartel="ECOSUMINISTROS";
	else if findw(upcase(rotulo_limpio), "EROSKI") then cartel="EROSKI";
	else if findw(upcase(rotulo_limpio), "EXOIL") then cartel="EXOIL";
	else if findw(upcase(rotulo_limpio), "FAMILY ENERGY") then cartel="FAMILY ENERGY";
	else if findw(upcase(rotulo_limpio), "FAST FUEL") then cartel="FAST FUEL";
	else if findw(upcase(rotulo_limpio), "GACOSUR") then cartel="GACOSUR";
	else if findw(upcase(rotulo_limpio), "RUNNER") then cartel="GAS RUNNER";
	else if findw(upcase(rotulo_limpio), "GASEXPRESS") then cartel="GASEXPRESS";
	else if findw(upcase(rotulo_limpio), "GHC") then cartel="GHC";
	else if findw(upcase(rotulo_limpio), "GLOBALTANK") then cartel="GLOBALTANK";
	else if findw(upcase(rotulo_limpio), "GP") then cartel="GP";
	else if findw(upcase(rotulo_limpio), "HAFESA") then cartel="HAFESA";
	else if findw(upcase(rotulo_limpio), "IBERDOEX") then cartel="IBERDOEX";
	else if findw(upcase(rotulo_limpio), "INLOCOR") then cartel="INLOCOR";
	else if findw(upcase(rotulo_limpio), "JAENCOOP") then cartel="JAENCOOP";
	else if findw(upcase(rotulo_limpio), "JULIA-OIL") then cartel="JULIA-OIL";
	else if findw(upcase(rotulo_limpio), "LABOIL") then cartel="LABOIL";
	else if findw(upcase(rotulo_limpio), "LLORSOIL") then cartel="LLORSOIL";
	else if findw(upcase(rotulo_limpio), "MEROIL") then cartel="MEROIL";
	else if findw(upcase(rotulo_limpio), "MINIOIL") then cartel="MINIOIL";
	else if findw(upcase(rotulo_limpio), "MKT") then cartel="MKTOIL";
	else if findw(upcase(rotulo_limpio), "BAROL") then cartel="OIL BAROL";
	else if findw(upcase(rotulo_limpio), "PRIX") then cartel="OILPRIX";
	else if findw(upcase(rotulo_limpio), "OPTYME") then cartel="OPTYME";
	else if findw(upcase(rotulo_limpio), "PCAN") then cartel="PCAN";
	else if findw(upcase(rotulo_limpio), "PETROCASH") then cartel="PETROCASH";
	else if findw(upcase(rotulo_limpio), "PETROCAT") then cartel="PETROCAT";
	else if findw(upcase(rotulo_limpio), "PETROMAX") then cartel="PETROMAX";
	else if findw(upcase(rotulo_limpio), "PETROMIRALLES") then cartel="PETROMIRALLES";
	else if findw(upcase(rotulo_limpio), "PETRONIEVES") then cartel="PETRONIEVES";
	else if findw(upcase(rotulo_limpio), "Q8") then cartel="Q8";
	else if findw(upcase(rotulo_limpio), "REPOSTAR") OR findw(upcase(rotulo_limpio), "REPOSTAR.")then cartel="REPOSTAR";
    else if findw(upcase(rotulo_limpio), "ROYMAGA") then cartel="ROYMAGA";
	else if findw(upcase(rotulo_limpio), "SARAS") then cartel="SARAS";
	else if findw(upcase(rotulo_limpio), "STAROIL") then cartel="STAROIL";
	else if findw(upcase(rotulo_limpio), "TAMOIL") then cartel="TAMOIL";
	else if findw(upcase(rotulo_limpio), "TECNOIL") then cartel="TECNOIL";
	else if findw(upcase(rotulo_limpio), "TGAS") then cartel="TGAS";
	else if findw(upcase(rotulo_limpio), "VALCARCE") then cartel="VALCARCE";
	else if findw(upcase(rotulo_limpio), "ZOIL") then cartel="ZOIL";
	else cartel=rotulo_limpio;

    drop rotulo rotulo_limpio;

   
run;

/*Analisis de frecuencias de la variable cartel*/

proc freq data=gasolina95;
  tables cartel;
run;

/*Procedo a eliminar valores missing*/

data gasolina95;
  set gasolina95;
  if cartel in ("(SIN RÓTULO)", "(sin rótulo)", "-", "06/32718", "15909", "23ESO68F", "63182867", "7267", "7345", "96053", 
                "A800-02", "NINGUNO", "NO", "NO ROTULO", "NO TIENE", "Nº 10.935", "Nº 15.526", "Nº 7374", "SIN DETERMINAR", "SIN ROTULO")
     then delete;

run;

proc freq data=gasolina95 ORDER=freq;
  tables cartel;
run;


/*Me quedo con las 15 más frecuentes y el resto las agrupo como RESTO*/

data gasolina95;
  set gasolina95;
  if cartel not in ("REPSOL", "CEPSA", "BP", "GALP", "SHELL", "PETRONOR", "AVIA", "CAMPSA", "CARREFOUR", "DISA", 
                "BALLENOIL", "SARAS", "PETROPRIX", "AGLA", "MEROIL")
     then cartel="RESTO";

run;

proc freq data=gasolina95 ORDER=freq;
  tables cartel;
run;





/*Analisis de la variable Tipo_venta*/

proc freq data=gasolina95;
  tables Tipo_venta;
run;

/*Solo sale un Tipo_venta así que no nos aporta información y podemos eliminarla del estudio*/
data gasolina95;
  set gasolina95;
  drop Tipo_venta;
run;

/*Analisis de la variable Rem*/

proc freq data=gasolina95;
  tables Rem;
run;

/*Analisis de la variable Horario*/
/*Creo dos nuevas variables: dia y atencion*/


data gasolina95; 
 set gasolina95 ; 
 if find( horario, "D") then dia="L-D"; 
 else if find( horario, "S") then dia="L-S"; 
 else if find( horario, "V") then dia="L-V"; 
 else if find( horario, "J") then dia="L-J"; 
 else dia= tranwrd ( horario, ":", "");
run;

proc freq data=gasolina95;
  tables dia;
run;


/*Variable atencion*/

 data gasolina95;  
   set gasolina95;  
      format atencion $10.;  
      if find( horario, "24H") then atencion="24H";    
      else atencion = "NO ES 24H";  
 run; 


 proc freq data=gasolina95;
  tables atencion;
run;


data gasolina95;
  set gasolina95;
  drop horario;
run;

data lib_in.gasolina1;
  set gasolina95;
run;

data gasolina95;
  set lib_in.gasolina1;
run;

/*Analisis de variables analíticas*/

proc means data=gasolina95;
  var _numeric_;
run;


/*elimino variables con muy pocas observaciones*/
data gasolina95;
  set gasolina95;
  drop porcentaje_ester_metilico porcentaje_bioalcohol Precio_gas_natural_licuado 
       Precio_gas_natural_comprimido Precio_bioetanol Precio_biodiesel;
run;

/*Estudio de correlación*/
proc corr data=gasolina95 outs=correlaciones;
  var _numeric_; 
run;

/*Nuestro objetivo es el precio de la gasolina de 95 desde el punto de vista del consumidor así que voy 
a eliminar el resto de precios del estudio*/

data gasolina95;
  set gasolina95;
  drop Precio_gasoleo_A Precio_gasoleo_B Precio_nuevo_gasoleo_A 
       Precio_gasolina_98 Precio_gases_licuados_del_petrol;
run;



/*MODELADO*/
data lib_in.gasolina95_limpio;
  set gasolina95;
run;

/*Analisis de normalidad*/

proc univariate data=lib_in.gasolina95_limpio   normal plot;     
   var precio_gasolina_95;  
   qqplot precio_gasolina_95    / NORMAL (MU=EST SIGMA=EST COLOR=RED L=1);   
    HISTOGRAM / NORMAL(COLOR=MAROON W=4) CFILL = pink CFRAME = LIGR;   
    INSET MEAN STD /CFILL=BLANK FORMAT=5.2; 
run;

/*Modelo GLM*/

/* Nº observaciones: 58775*/
/*70% entrenamiento: 41.143*/
/*15% validación: 8.816*/
/*15% test: 8.816*/

/*Creo las particiones*/

data gasolina95_train gasolina95_valida gasolina95_test;   
     set lib_in.gasolina95_limpio;    
     if _N_ <= 41143 then output gasolina95_train;    
     else if _N_ <= 49959 then output gasolina95_valida;     
     else output gasolina95_test; 
run; 

/*Modelo GLM Select*/

/*Sin interacciones, 200 modelos, semilla: 12345*/
/*MACRO*/

%let lib= "/home/u44690176/my_courses/Mariceli/mariceli0/output/macrogas95_1.txt"; 
 
%macro macro_GLM_select; 
%do semilla=12345 %to 12545; 
  ods graphics on; 
  ods output SelectionSummary=modelos; 
  ods output SelectedEffects=efectos; 
  ods output Glmselect.SelectedModel.FitStatistics=ajuste; 
 
  proc glmselect data=gasolina95_train plots=all seed=&semilla;      
  partition fraction(validate=0.4);  
  class Fecha Provincia Margen Rem zona cartel dia atencion; 
  model precio_gasolina_95 = Fecha Provincia Margen Rem zona cartel dia atencion   
    / selection=stepwise(select=aic choose=cv) details=all stats=all; 
  run;   
  ods graphics off;    
  ods html close;    
  data union; i=12; set efectos; set ajuste point=i; run; 
  data;semilla=&semilla;file &lib mod;set union;put effects @80 nvalue1 @95 semilla;run; 
%end;
proc sql; drop table modelos,efectos,ajuste,union; quit;
%mend; 
 
%macro_GLM_select; 

data modelo_sin_interacciones; 
length modelo $100; 
input modelo $1-76 ase semilla;
cards;
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001189       12345
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001170       12346
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001165       12347
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001177       12348
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001214       12349
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001173       12350
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001157       12351
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001185       12352
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001179       12353
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12354
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001181       12355
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001191       12356
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001167       12357
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001176       12358
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12359
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12360
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001184       12361
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001204       12362
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001196       12363
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001177       12364
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001156       12365
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001194       12366
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12367
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001192       12368
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001190       12369
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001181       12370
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001166       12371
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001195       12372
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001176       12373
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001145       12374
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001159       12375
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001185       12376
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001195       12377
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001156       12378
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001180       12379
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001205       12380
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001168       12381
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001177       12382
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001182       12383
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001161       12384
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001194       12385
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001177       12386
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12387
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001158       12388
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001158       12389
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001185       12390
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001170       12391
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001222       12392
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001152       12393
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001182       12394
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001184       12395
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12396
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001170       12397
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001158       12398
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001164       12399
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12400
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001184       12401
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001185       12402
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001172       12403
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001167       12404
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001188       12405
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001153       12406
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001166       12407
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12408
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001199       12409
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001193       12410
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001170       12411
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001160       12412
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001156       12413
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001147       12414
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001174       12415
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001183       12416
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001177       12417
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001190       12418
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12419
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12420
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001169       12421
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12422
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001158       12423
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001196       12424
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001172       12425
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12426
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001169       12427
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001162       12428
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001182       12429
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001163       12430
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001174       12431
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12432
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001146       12433
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001182       12434
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001167       12435
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12436
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001167       12437
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001159       12438
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001208       12439
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001156       12440
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001161       12441
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001181       12442
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12443
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001173       12444
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001150       12445
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001172       12446
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001154       12447
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001155       12448
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001190       12449
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001163       12450
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001183       12451
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001181       12452
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001177       12453
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001153       12454
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001163       12455
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001172       12456
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001149       12457
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001182       12458
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001172       12459
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12460
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001183       12461
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001159       12462
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001191       12463
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001181       12464
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001195       12465
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001173       12466
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12467
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001184       12468
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001166       12469
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001150       12470
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001189       12471
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001199       12472
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001196       12473
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12474
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001164       12475
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12476
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001184       12477
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12478
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001195       12479
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001157       12480
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001158       12481
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001189       12482
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001174       12483
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12484
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001173       12485
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001200       12486
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001147       12487
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001184       12488
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001172       12489
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001179       12490
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001194       12491
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001155       12492
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001163       12493
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001196       12494
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001144       12495
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001165       12496
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001192       12497
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001167       12498
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001168       12499
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001192       12500
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001182       12501
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001194       12502
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001185       12503
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001154       12504
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001185       12505
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001155       12506
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001193       12507
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001153       12508
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001182       12509
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001179       12510
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001171       12511
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001192       12512
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001174       12513
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001149       12514
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001169       12515
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001164       12516
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001177       12517
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001169       12518
Intercept Fecha Provincia Margen Rem zona cartel dia atencion                  0.001158       12519
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001180       12520
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001207       12521
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001185       12522
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001204       12523
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001176       12524
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001174       12525
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001170       12526
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001165       12527
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001175       12528
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001197       12529
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001184       12530
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001163       12531
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001201       12532
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001174       12533
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001179       12534
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001164       12535
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001201       12536
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001176       12537
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001166       12538
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001159       12539
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001178       12540
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001158       12541
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001169       12542
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001192       12543
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001160       12544
Intercept Provincia Margen Rem zona cartel dia atencion                        0.001183       12545

run;

proc sql;  
  create table modelos_sin_interacciones as  
  select modelo as Modelo_GLM_sin_interacciones, 
         count(modelo) as Count_model, min(ase) as Min_Ase, max(ase) as Max_Ase, 
         avg(ase) as AVG_Ase, STD(ase) as STD_Ase  
  from modelo_sin_interacciones   
  group by modelo   
  order by Count_model desc;   
quit;


/*Macro con interacciones*/

%let lib= "/home/u44690176/my_courses/Mariceli/mariceli0/output/macrogas95_8.txt"; 
 
%macro macro_GLM_select_int; 
/*12345 - 12395 _2.txt
/*12396 - 12446 _3.txt*/
/*12447 - 12457 _4.txt*/
/*12458 - 12497 _5.txt*/

/*12497*/
/*12508*/


%do semilla=12509 %to 12545;*12545; 
  ods graphics on; 
  ods output SelectionSummary=modelos; 
  ods output SelectedEffects=efectos; 
  ods output Glmselect.SelectedModel.FitStatistics=ajuste; 
 
  proc glmselect data=gasolina95_train plots=all seed=&semilla;      
  partition fraction(validate=0.4);  
  class Fecha Provincia Margen Rem zona cartel dia atencion; 
  model precio_gasolina_95 = Fecha*Provincia Fecha*Margen Fecha*Rem Fecha*zona Fecha*cartel
                             Fecha*dia Fecha*atencion Provincia*Margen Provincia*Rem  
                             Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion
                             Margen*Rem Margen*zona Margen*cartel Margen*dia Margen*atencion
                             Rem*zona Rem*cartel Rem*dia Rem*atencion zona*cartel zona*dia
                             zona*atencion cartel*dia cartel*atencion dia*atencion
   
    / selection=stepwise(select=aic choose=cv) details=all stats=all; 
  run;   
  ods graphics off;    
  ods html close;    
  data union; i=12; set efectos; set ajuste point=i; run; 
  data;semilla=&semilla;file &lib mod;set union;put effects @450 nvalue1 @465 semilla;run; 
%end;
proc sql; drop table modelos,efectos,ajuste,union; quit;
%mend; 
 
%macro_GLM_select_int; 


data modelo_con_interacciones; 
length modelo $500; 
input modelo $1-400 ase semilla;
cards;
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000916       12345
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000915       12346
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000903       12347
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000948       12348
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000981       12349
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000895       12350
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                         0.000897       12351
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000916       12352
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000925       12353
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000923       12354
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000905       12355
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                              0.000923       12356
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                               0.000913       12357
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*zona Margen*cartel Margen*dia Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                  0.000902       12358
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000900       12359
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000915       12360
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*zona Margen*cartel Margen*dia Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                  0.000912       12361
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000951       12362
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000919       12363
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000908       12364
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000897       12365
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000915       12366
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000915       12367
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                     0.000908       12368
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000926       12369
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000907       12370
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000903       12371
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000938       12372
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                         0.000926       12373
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000887       12374
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000907       12375
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000908       12376
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000941       12377
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                             0.000913       12378
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                     0.000912       12379
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000935       12380
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000928       12381
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*atencion                                                                                                                                                                                                                                                                                                        0.000943       12382
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*zona Margen*cartel Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                             0.000903       12383
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000887       12384
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                             0.000931       12385
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                   0.000894       12386
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000895       12387
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000918       12388
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000914       12389
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000910       12390
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000903       12391
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*zona Margen*cartel Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                             0.000928       12392
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000895       12393
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                         0.000929       12394
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000931       12395
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                               0.000897       12396
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000896       12397
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                   0.000911       12398
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000924       12399
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000896       12400
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                         0.000918       12401
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000908       12402
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000918       12403
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000913       12404
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000911       12405
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000911       12406
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000921       12407
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000928       12408
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000946       12409
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000956       12410
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000915       12411
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                      0.000915       12412
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000897       12413
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000910       12414
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                      0.000955       12415
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000944       12416
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000909       12417
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000926       12418
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000916       12419
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000922       12420
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000915       12421
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000927       12422
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                      0.000932       12423
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000934       12424
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*zona Margen*cartel Margen*dia Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                  0.000892       12425
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000930       12426
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000910       12427
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000923       12428
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000942       12429
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000906       12430
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000925       12431
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000919       12432
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000904       12433
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                   0.000927       12434
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000888       12435
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000924       12436
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000911       12437
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                             0.000926       12438
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000958       12439
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000902       12440
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                      0.000902       12441
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000904       12442
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000917       12443
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                            0.000909       12444
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000896       12445
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000891       12446
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000885       12447
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000917       12448
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000935       12449
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000917       12450
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*zona Margen*cartel Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                             0.000925       12451
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000908       12452
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                      0.000911       12453
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000883       12454
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000951       12455
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000909       12456
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                      0.000900       12457
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000918       12458
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                              0.000921       12459
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000918       12460
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000923       12461
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                      0.000912       12462
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                    0.000943       12463
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000939       12464
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000934       12465
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                              0.000901       12466
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000946       12467
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000931       12468
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000896       12469
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000911       12470
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                   0.000948       12471
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                         0.000930       12472
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000948       12473
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000933       12474
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000909       12475
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000913       12476
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                               0.000938       12477
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000918       12478
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000943       12479
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000897       12480
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000930       12481
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000908       12482
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                               0.000927       12483
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                     0.000934       12484
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*zona Margen*cartel Margen*dia Margen*atencion Rem*cartel Rem*atencion zona*cartel zona*dia zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                  0.000924       12485
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                              0.000927       12486
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000900       12487
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000917       12488
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000901       12489
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000922       12490
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000916       12491
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000895       12492
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                               0.000906       12493
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000924       12494
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000899       12495
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000908       12496
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000940       12497
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000918       12498
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                               0.000913       12499
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                         0.000945       12500
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000910       12501
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000945       12502
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000918       12503
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000903       12504
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000928       12505
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000914       12506
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000937       12507
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                   0.000890       12508
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000920       12509
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000921       12510
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000913       12511
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000939       12512
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000910       12513
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000878       12514
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                            0.000903       12515
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                                          0.000908       12516
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                     0.000923       12517
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*atencion cartel*dia cartel*atencion                                                                                                                                                                                                                                                               0.000895       12518
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000903       12519
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000925       12520
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000943       12521
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000934       12522
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                   0.000949       12523
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                  0.000922       12524
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                  0.000914       12525
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000918       12526
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000925       12527
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000906       12528
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000942       12529
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000918       12530
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000900       12531
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000923       12532
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                    0.000930       12533
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                   0.000960       12534
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                    0.000914       12535
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000949       12536
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000951       12537
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                             0.000906       12538
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000920       12539
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*Rem Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                           0.000916       12540
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                    0.000898       12541
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion                                                                                                                                                                                                                                                                               0.000903       12542
Intercept Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Margen*cartel Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                        0.000954       12543
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion zona*cartel cartel*atencion                                                                                                                                                                                                                                                                                                                                             0.000944       12544
Intercept Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion Rem*cartel zona*cartel cartel*dia cartel*atencion                                                                                                                                                                                                                                                                                                                       0.000916       12545

run;

proc sql;  
  create table modelos_con_interacciones as  
  select modelo as Modelo_GLM_con_interacciones, 
         count(modelo) as Count_model, min(ase) as Min_Ase, max(ase) as Max_Ase, 
         avg(ase) as AVG_Ase, STD(ase) as STD_Ase  
  from modelo_con_interacciones   
  group by modelo   
  order by Count_model desc;   
quit;

/*Integro todos los modelos en una unica tabla y ordeno por frecuencia de los modelos y por el ASE de manera descendente*/

data all_model;  
  set modelos_sin_interacciones (rename=Modelo_GLM_sin_interacciones = Modelo_GLM)      
      modelos_con_interacciones (rename=Modelo_GLM_con_interacciones = Modelo_GLM);
run; 
 
proc sort data=all_model; 
  by descending Count_model AVG_Ase Min_Ase Max_Ase;
run; 


/* Primer modelo*/
proc glm data=gasolina95_train; 
   class Provincia Margen Rem zona cartel dia atencion;
   model precio_gasolina_95 = Provincia Margen Rem zona cartel dia atencion       
  / solution e; 
run; 

/*Segundo modelo*/

 proc glm data=gasolina95_train; 
   class Provincia Margen Rem zona cartel dia atencion;
   model precio_gasolina_95 = Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion
                              Margen*Rem Margen*Cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion
  / solution e; 
run; 


/*Me quedo con el modelo de las interacciones*/
/*R cuadrado 0.8561*/

/*Comprubo la robutez del modelo con las muestras de valicación*/
proc glm data=gasolina95_valida; 
   class Provincia Margen Rem zona cartel dia atencion;
   model precio_gasolina_95 = Provincia*Margen Provincia*Rem Provincia*zona Provincia*cartel Provincia*dia Provincia*atencion
                              Margen*Rem Margen*Cartel Rem*cartel zona*cartel zona*dia cartel*dia cartel*atencion
  / solution e; 
run; 

/*R cuadrado de 0.8718*/
/*es bastante parecido por lo que podemos considerar que el modelo es robusto*/




















GOPTIONS NOACCESSIBLE;
%LET _CLIENTTASKLABEL=;
%LET _CLIENTPROCESSFLOWNAME=;
%LET _CLIENTPROJECTPATH=;
%LET _CLIENTPROJECTPATHHOST=;
%LET _CLIENTPROJECTNAME=;
%LET _SASPROGRAMFILE=;
%LET _SASPROGRAMFILEHOST=;

;*';*";*/;quit;run;
ODS _ALL_ CLOSE;
