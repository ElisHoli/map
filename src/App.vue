<script>
  import Departures from "@/components/Departures.vue";
  import axios from "axios";
  import dayjs from "dayjs";

  const apikey = import.meta.env.VITE_API_KEY;

  export default {
    name: "Mapa",
    components: {Departures},
    methods: {
      formatDate(dateString) {
        const date = dayjs(dateString);
        return date.format('HH:mm');
      }
    },
    data() {
      return {
        list:[]
      };
    },

    async mounted() {
      axios.defaults.headers.common['x-access-token'] = `${apikey}`
      let result = await axios.get("https://api.golemio.cz/v2/vehiclepositions?limit=1000&offset=0");
      //console.log(result);
      this.list = result.data.features;
    },
  };
</script>
<template>
  <header>
    <div class="wrapper">
      <ul class="nav nav-tabs nav-fill" id="myTab" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link active" id="departures-tab" data-bs-toggle="tab" data-bs-target="#departures-tab-pane" type="button" role="tab" aria-controls="departures-tab-pane" aria-selected="true">Odjezdová tabule</button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="home-tab" data-bs-toggle="tab" data-bs-target="#home-tab-pane" type="button" role="tab" aria-controls="home-tab-pane" aria-selected="false" disabled>Aktuální odjezdy</button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="profile-tab" data-bs-toggle="tab" data-bs-target="#profile-tab-pane" type="button" role="tab" aria-controls="profile-tab-pane" aria-selected="false" disabled>Vyhledání spoje</button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="contact-tab" data-bs-toggle="tab" data-bs-target="#contact-tab-pane" type="button" role="tab" aria-controls="contact-tab-pane" aria-selected="false" disabled>Mapa</button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="disabled-tab" data-bs-toggle="tab" data-bs-target="#disabled-tab-pane" type="button" role="tab" aria-controls="disabled-tab-pane" aria-selected="false" disabled>Disabled</button>
        </li>
      </ul>
    </div>
  </header>

  <main>
    <div class="tab-content" id="myTabContent">
      <!-- Aktuální odjezdy -->
      <div class="tab-pane fade" id="home-tab-pane" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
        <Departures />
      </div>
      <!-- Odjezdová tabule -->
      <div class="tab-pane fade show active" id="departures-tab-pane" role="tabpanel" aria-labelledby="departures-tab" tabindex="0">
        <Departures />
      </div>
      <!-- Seznam spojů -->
      <div class="tab-pane fade" id="profile-tab-pane" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
        <p v-for="item in list" :key="item.id" :class="[item.properties.trip.vehicle_type?.description_cs === 'tramvaj' ? 'tram' : item.properties.trip.vehicle_type?.description_cs === 'autobus' ? 'bus' : item.properties.trip.vehicle_type?.description_cs === 'regionální autobus' ? 'regBus' : '']">
          {{item.properties.trip.vehicle_type?.description_cs}} {{item.properties.trip.gtfs.route_short_name}} ({{item.properties.trip.gtfs.trip_headsign}}) - GPS {{item.geometry.coordinates}} - start {{formatDate(item.properties.trip.start_timestamp)}}
        </p>
      </div>
      <!-- Mapa -->
      <div class="tab-pane fade" id="contact-tab-pane" role="tabpanel" aria-labelledby="contact-tab" tabindex="0">...</div>
      <div class="tab-pane fade" id="disabled-tab-pane" role="tabpanel" aria-labelledby="disabled-tab" tabindex="0">...</div>
    </div>
  </main>
</template>

<style scoped>

</style>
