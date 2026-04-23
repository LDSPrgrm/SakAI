package usecase

import (
	"testing"

	"github.com/sakai/backend/internal/domain"
)

func TestFindZoneMultiplier_PointInside(t *testing.T) {
	// Square around Makati CBD (rough): corners at (14.55,121.00), (14.55,121.05),
	// (14.60,121.05), (14.60,121.00).
	zones := []SurgeZone{{
		Name:       "Makati CBD",
		Multiplier: 1.8,
		Polygon: [][]float64{
			{14.55, 121.00},
			{14.55, 121.05},
			{14.60, 121.05},
			{14.60, 121.00},
		},
	}}

	name, m, ok := FindZoneMultiplier(zones, domain.LatLng{Lat: 14.57, Lng: 121.03})
	if !ok {
		t.Fatal("expected point inside zone")
	}
	if name != "Makati CBD" || m != 1.8 {
		t.Fatalf("wrong match: %q %v", name, m)
	}
}

func TestFindZoneMultiplier_PointOutside(t *testing.T) {
	zones := []SurgeZone{{
		Name:       "Test",
		Multiplier: 2.0,
		Polygon: [][]float64{
			{14.55, 121.00}, {14.55, 121.05}, {14.60, 121.05}, {14.60, 121.00},
		},
	}}

	if _, _, ok := FindZoneMultiplier(zones, domain.LatLng{Lat: 14.70, Lng: 121.10}); ok {
		t.Fatal("expected point outside all zones")
	}
}

func TestFindZoneMultiplier_EmptyZones(t *testing.T) {
	if _, _, ok := FindZoneMultiplier(nil, domain.LatLng{Lat: 1, Lng: 1}); ok {
		t.Fatal("expected no match with no zones")
	}
}

func TestParseSurgeZones_Invalid(t *testing.T) {
	if got := ParseSurgeZones([]byte("not json")); got != nil {
		t.Fatalf("expected nil on invalid json, got %v", got)
	}
	if got := ParseSurgeZones(nil); got != nil {
		t.Fatalf("expected nil on empty, got %v", got)
	}
}

func TestParseSurgeZones_Roundtrip(t *testing.T) {
	raw := []byte(`[{"name":"A","multiplier":1.5,"polygon":[[0,0],[0,1],[1,1],[1,0]]}]`)
	zones := ParseSurgeZones(raw)
	if len(zones) != 1 || zones[0].Name != "A" || zones[0].Multiplier != 1.5 {
		t.Fatalf("unexpected parse result: %+v", zones)
	}
}
