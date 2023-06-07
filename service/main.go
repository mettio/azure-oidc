package main

import (
	"net/http"
	"os"

	echo "github.com/labstack/echo/v4"
	middleware "github.com/labstack/echo/v4/middleware"
)

type Station struct {
	Index    int    `json:"index"`
	Uuid     string `json:"uuid"`
	Id       string `json:"id"`
	LongName string `json:"longName"`
	Name     string `json:"name"`
}

type Error struct {
	ErrorNo      int    `json:errno`
	ErrorMessage string `json:message`
}

func station(uuid string) Station {
	for _, v := range stations() {
		if v.Uuid == uuid {
			return v
		}
	}
	return Station{}
}

func stations() []Station {
	return []Station{
		{Index: 0, Uuid: "7ca07941-7877-4dad-a903-6670ece73fff", Id: "hydra", LongName: "The Hydra Station", Name: "Hydra"},
		{Index: 1, Uuid: "a1dcc655-e6af-4225-9509-ad048305279f", Id: "tempest", LongName: "The Tempest Station", Name: "Tempest"},
		{Index: 2, Uuid: "0cbf7d54-1b61-4126-bf45-eb81ae407439", Id: "arrow", LongName: "The Arrow Station", Name: "Arrow"},
		{Index: 3, Uuid: "13016211-f77e-49c1-b27c-d0daab09cfb4", Id: "swan", LongName: "The Swan Station", Name: "Swan"},
		{Index: 4, Uuid: "9820cd8d-ddea-494f-98b2-c77c55221377", Id: "flame", LongName: "The Flame Station", Name: "Flame"},
		{Index: 5, Uuid: "9f989fc4-5029-4fe2-be66-a3d25b92a77b", Id: "pearl", LongName: "The Pearl Station", Name: "Pearl"},
		{Index: 6, Uuid: "8d3fbb83-752a-4d50-be40-78d66ac8cbef", Id: "orchid", LongName: "The Orchid Station", Name: "Orchid"},
		{Index: 7, Uuid: "05dc55cc-15e0-4eec-8a0c-d390a81cb94f", Id: "staff", LongName: "The Staff Station", Name: "Staff"},
	}
}

func main() {
	e := echo.New()

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowHeaders: []string{echo.HeaderOrigin, echo.HeaderContentType, echo.HeaderAccept},
	}))

	e.GET("/api/v1/health", func(c echo.Context) error {
		return c.JSON(http.StatusOK, struct{ Status string }{Status: "OK"})
	})

	e.GET("/api/v1/stations", func(c echo.Context) error {
		return c.JSON(http.StatusOK, stations())
	})

	e.GET("/api/v1/stations/:uuid", func(c echo.Context) error {
		uuid := c.Param("uuid")
		station := station(uuid)

		if station != (Station{}) {
			return c.JSON(http.StatusOK, station)
		}

		return c.JSON(http.StatusNotFound, Error{ErrorNo: 1, ErrorMessage: "Station not found"})
	})

	p := os.Getenv("HTTP_PORT")
	if p == "" {
		p = "3000"
	}

	e.Logger.Fatal(e.Start(":" + p))
}
