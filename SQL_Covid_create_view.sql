CREATE VIEW PercentPopulationVaccinated  as
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
    ,sum(convert(int,vac.new_vaccinations)) 
    OVER (PARTITION BY dea.LOCATION ORDER BY dea.Location, dea.date) as rollingpeoplevaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
JOIN [Project Portfolio]..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.[date] = vac.date 
WHERE dea.continent is not null 
--order by 1,2,3