# Práctica: Módulo Data Mining - SAS - Bootcamp KeepCoding - BIG DATA & MACHINE LEARNING

# Módulo Data Mining - SAS

Durante esta práctica se utiliza SAS (Statistical Analysis System). SAS es una de las herramientas 
de análisis de datos más extendida y es capaz de trabajar grandes volúmenes de datos de manera ágil dando una respuesta
muy rápida. SAS tiene más de 200 componentes. Durante esta práctica se utiliza **SAS/BASE, SAS/Studio, SAS/Guide y SAS/Miner**

Conceptos tratados en esta práctica:

- Data Cooking
   - Análisis de la variable objetivo: Missings, outliers, duplicidades, incongruencias
   - Análisis estadístico de la variable objetivo
   - Análisis de variables categóricas: Missings, outliers, eliminación de variables con información redundante, generación de nuevas características de interés
   - Análisis de variables analíticas: estadísticios básicos, missings, outliers, eliminación de variables, estudio de correlación
   
- Análisis de normalidad
- Modelo lineal general (GLM): 
    - Obtención de efectos que intervienen en el modelo (entrenamiento con y sin interacciones en el modelo)
    - Análisis de errores
    - Selección de modelo
    - Test del modelo
    
- Uso de SAS/Miner para comparar modelos:
     - GLM, Regresión Lineal, Redes Neuronales
  

## Enunciado

El objetivo de la práctica es abordar un problema de data mining realista siguiendo la metodología y buenas prácticas explicadas durante las clases teóricas.

La fuente de datos recoge la información actualizada diariamente de los precios de los combustibles en España. Donde muestra las gasolineras y se puede consultar el precio, horario, marca y fecha de actualización del dato. Los datos sobre las gasolineras proceden del Ministerio de Energía, Turismo y Agenda Digital.

Se trabajará con los precios oficiales y gratuitos sobre los precios de la gasolina de las gasolineras en España, el tiempo recogido será de una semana completa (de lunes a domingo).

- **Fuente** (datos oficiales del gobierno español): https://datos.gob.es/es/catalogo/e04990201-precio-de-carburantes-en-lasgasolineras-espanolas

- **Modelización:** GLM y su comparativa con Regresión y Redes Neuronales

- **Objetivo:** predecir el precio de la gasolina 95 en España a nivel de provincia, desde el punto de vista del consumidor.
