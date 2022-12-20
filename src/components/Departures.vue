<script>
import axios from "axios";
import dayjs from "dayjs";

export default {
  name: "Departures",
  methods: {
    formatDate(dateString) {
      const date = dayjs(dateString);
      return date.format('HH:mm');
    },
    countTime(now, departure) {
      const mins = dayjs(departure) - dayjs(now);
      return dayjs(mins).format('m');
    }
  },
  data() {
    return {
      list: [],
      now: '',
      vehicle: ''
    };
  },
  async mounted() {
    const access_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImVsaXNrYWhvbHpAc2V6bmFtLmN6IiwiaWQiOjE1ODYsIm5hbWUiOm51bGwsInN1cm5hbWUiOm51bGwsImlhdCI6MTY3MTQ1OTU4MCwiZXhwIjoxMTY3MTQ1OTU4MCwiaXNzIjoiZ29sZW1pbyIsImp0aSI6ImY3Y2Q0NmJlLWIyYTEtNDFiOS1hZmVlLTczYzgyZTRlMWM5OSJ9.LoMdVi-3_j_a3VjgS_1woumj0byOw9j3q8FWkaPS608"
    axios.defaults.headers.common['x-access-token'] = `${access_token}`
    const now = new Date()
    const time = now.toISOString()
    this.now = time;

    //&minutesBefore=5

    let result = await axios.get("https://api.golemio.cz/v2/pid/departureboards?names=Slánská&minutesAfter=60&timeFrom=" + time + "&includeMetroTrains=true&mode=departures&order=real&filter=routeOnce&skip=canceled");
    console.log("Departures")
    console.log(result)
    this.list = result.data.departures
  },
  updated: function () {
    const now = new Date()
    const time = now.toISOString()
    setInterval(function () {
      axios
          .get("https://api.golemio.cz/v2/pid/departureboards?names=Slánská&minutesAfter=60&timeFrom=" + time + "&includeMetroTrains=true&mode=departures&order=real&filter=routeOnce&skip=canceled", {
            "Content-Type": "application/json",
          })
          .then(response => (
              console.log(response),
                  this.list = response.data.departures))
    }, 5000)
  }
};
</script>

<template>
  <div id="departuresForm">
    <!-- TODO: formulář pro výběr zastávky a času -->
<!--    <form>
      <div class="row">
        <div class="col-12 col-md-5 form-floating">
          <input type="text" class="form-control" id="stop" placeholder="Zastávka" value="Slánská">
          <label for="stop">Zastávka</label>
        </div>
        <div class="col-12 col-md-5 form-floating">
          <input type="datetime-local" class="form-control" id="time" placeholder="Odjezd">
          <label for="time">Odjezd</label>
        </div>
        <div class="col-12 col-md-2">
          <input type="submit" class="btn btn-primary" value="Zobrazit">
        </div>
      </div>
    </form>-->
    <h2>Ze zastávky <strong>Slánská</strong> v <strong>{{formatDate(now)}}</strong></h2>
  </div>
  <div class="card departures" v-for="item in list" :key="item.id">
    <div class="card-header">
      <div class="row">
        <div class="col-6">
          za {{ countTime(time, item.arrival_timestamp.predicted) }} min <span
            v-if="item.delay.is_available && item.delay.minutes > 0">včetně zpoždění</span>
        </div>
        <div class="col-6 text-end">
          <span v-if="item.delay.is_available && item.delay.minutes === 0" class="badge bg-success">včas</span>
          <span v-else-if="item.delay.is_available && item.delay.minutes > 0"
                class="badge bg-danger">zpoždění {{ item.delay.minutes }} min</span>
        </div>
      </div>

    </div>
    <div class="card-body">
      <h5 class="card-title">
        <div class="row">
          <!-- TODO: typ vozidla (tram, bus, metro, ...)-->
          <div class="col-9">{{ item.route.short_name }} <span class="text-black-50 ">směr {{ item.trip.headsign }}</span></div>
          <div class="col-3 text-end">{{ formatDate(item.arrival_timestamp.scheduled) }}</div>
        </div>
      </h5>

      <!--      <p class="card-text">With supporting text below as a natural lead-in to additional content.</p>-->
      <!--      <a href="#" class="btn btn-primary">Jízdní řád</a>-->
      <!--      <a href="#" class="btn btn-primary">Zobrazit na mapě</a>-->
    </div>
  </div>
</template>

<style scoped>
#departuresForm {
  margin-block: 16px;
}

#departuresForm input {
  margin-block: 8px;
}

#departuresForm .btn {
  width: 100%;
}

.card-title span {
  font-size: 13px;
}
</style>