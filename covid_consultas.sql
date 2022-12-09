
--seleccionando los datos con los que vamos a empezar a trabajar
Select Location, date,continent, total_cases, new_cases, total_deaths, population
From covid_muertes
Where continent is null 
order by 3,4

--mostrando el porcentaje de muerte de los infectados en Mexico, por dia
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as porcentaje_de_muerte
From covid_muertes
Where location='mexico'
order by 1,2 


--mostrando el porcentaje de infectados en cada pais, por dia
Select Location, date, Population, total_cases,  (total_cases/population)*100 as porcentaje_de_infectados
From covid_muertes
Where continent is not null 
order by 1,2

--Paises con la taza de infeccion mas alta en comparacion con la poblacion
Select Location, Population, MAX(total_cases) as mayor_total_de_casos,  Max((total_cases/population))*100 as Porcentaje_de_infectados_por_pais
From covid_muertes
Group by Location, Population
order by Porcentaje_de_infectados_por_pais desc

--Paises con mas muertes 
Select Location, MAX(cast(Total_deaths as int)) as conteo_de_muertes
From covid_muertes
Where continent is not null 
Group by Location
order by conteo_de_muertes desc

-- DESGLOSE POR CONTINENTE
-- Mostrando los continentes con el mayor recuento de muertes por población
Select continent, MAX(cast(Total_deaths as int)) as conteo_de_muertes
From covid_muertes
Where continent is not null 
Group by continent
order by conteo_de_muertes desc

--Porcentaje global de muertes
Select SUM(new_cases) as casos_totales, SUM(cast(new_deaths as int)) as muertes_totales, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as porcentaje_de_muerte
From covid_muertes
where continent is not null 

-- Población total vs vacunas
-- Muestra el porcentaje de población que ha recibido al menos una vacuna Covid

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as numero_vacunas_acumuladas
, ( SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/population)*100 as porcentaje_de_poblacion_vacunada
From covid_muertes dea
Join covid_vacunas vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and new_vaccinations is not null  
order by 2,3

--Muestra el porcentaje de población que ha recibido al menos una vacuna Covid en Mexico 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as numero_vacunas_acumuladas
, ( SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date)/population)*100 as porcentaje_de_poblacion_vacunada
From covid_muertes dea
Join covid_vacunas vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.location='Mexico' and new_vaccinations is not null 
order by 2,3

--Uso de cte para mejorar la consulta anterior
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, numero_vacunas_acumuladas)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as numero_vacunas_acumuladas
--, (RollingPeopleVaccinated/population)*100
From covid_muertes dea
Join covid_vacunas vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (numero_vacunas_acumuladas/Population)*100  porcentaje_de_poblacion_vacunada
From PopvsVac

--crear vista para almacenar datos para visuaizaciones posteriores
Create View porcentaje_poblacion_vacunada as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as  numero_vacunas_acumuladas

From covid_muertes dea
Join covid_vacunas vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 