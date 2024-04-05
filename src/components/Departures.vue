<script>
import axios from "axios";
import dayjs from "dayjs";
import "dayjs/plugin/relativeTime"

const apikey = import.meta.env.VITE_API_KEY;
axios.defaults.headers.common['x-access-token'] = `${apikey}`

export default {
  name: "Departures",
  methods: {
    getFormValues() {
      console.log(dayjs(this.$refs.time.value).format('YYYY-MM-DD HH:mm') >= this.$refs.time.min)
      console.log(dayjs(this.$refs.time.value).format('YYYY-MM-DD HH:mm'))
      console.log(this.$refs.time.min)
      if ((this.$refs.stop.value !== '' || this.$refs.stop.value !== '-- Vyberte zastávku --') && this.$refs.time.value !== '' && dayjs(this.$refs.time.value).format('YYYY-MM-DD HH:mm') >= this.$refs.time.min) {
        this.departuresForm['stop'] = this.$refs.stop.value
        this.departuresForm['time'] = this.$refs.time.value

        this.$refs.stop.style = "border-color: #ced4da"
        this.$refs.time.style = "border-color: #ced4da"
      } else {
        //TODO: přidat hlášky
        if (this.$refs.stop.value === '' || this.$refs.stop.value === '-- Vyberte zastávku --') {
          this.$refs.stop.style = "border-color: #dc3545"
        } else {
          this.$refs.stop.style = "border-color: #ced4da"
        }
        if (this.$refs.time.value === '' || dayjs(this.$refs.time.value).format('YYYY-MM-DD HH:mm') < this.$refs.time.min) {
          this.$refs.time.style = "border-color: #dc3545"
        } else {
          this.$refs.time.style = "border-color: #ced4da"
        }
      }
    },
    dayjs,
    formatDateTime(dateString) {
      const date = dayjs(dateString);
      return date.format('DD. MM. YYYY HH:mm');
    },
    formatDate(dateString) {
      const date = dayjs(dateString);
      return date.format('DD. MM. YYYY');
    },
    formatTime(dateString) {
      const date = dayjs(dateString);
      return date.format('HH:mm');
    },
    formatMins(dateString) {
      const mins = dayjs(dateString);
      return mins.format('m');
    },
    formatSecs(dateString) {
      const secs = dayjs(dateString);
      return secs.format('s');
    },
    countTime(now, departure) {
      return dayjs(departure) - dayjs(now);
    },
    isBefore(now, departure) {
      return dayjs(now).isBefore(dayjs(departure))
    }
  }
  ,
  data() {
    return {
      errors: [],
      list: [],
      minTime: dayjs((new Date()).setHours((new Date()).getHours() - 7)).format('YYYY-MM-DD HH:mm'),
      vehiclesType: [],
      departuresForm: {stop: 'Hlavní nádraží', time: dayjs().format('YYYY-MM-DD HH:mm')},
      stops: [],
      stop: []
    };
  },
  mounted() {
    axios
        .get('./stops.json')
        .then(response => {
          this.stops = response.data.stopGroups,
              console.log(response.data.stopGroups)
        })
        .catch(error => console.error('Chyba při provádění dotazu:', error));

    /*fetch("https://data.pid.cz/stops/json/stops.json",{mode: 'no-cors'})
        // .then(response => response.json())
        .then(response => {
          this.stops = response.data.stopGroups,
              console.log(response.data.stopGroups)
        })

    /*fetch("http://data.pid.cz/stops/json/stops.json",{mode: 'no-cors'})
        .then(response => response.json())
        .then(data => (this.stops = data.stopGroups));*/
    /*axios
        .get("http://data.pid.cz/stops/json/stops.json",{withCredentials: false})
        .then(response => {
          this.stops = data.stopGroups
            });*/
  },
  created() {
    const onNewData = () => {
      axios
          .get("https://api.golemio.cz/v2/pid/departureboards?names=" + this.departuresForm['stop'] + "&minutesBefore=1&minutesAfter=60&timeFrom=" + this.departuresForm['time'] + "&includeMetroTrains=true&mode=departures&order=real&filter=routeOnce&skip=canceled", {
            "Content-Type": "application/json",
          })
          .then(response => (
              console.log(response.data.departures),
                  this.list = response.data.departures));

    }
    setInterval(onNewData, 1000);
  }
}
</script>

<template>
  <div id="departuresForm">
    <form>
      <div class="row align-items-center">
        <div class="col-12 col-md-5 form-floating">
<!--          <input type="text" class="form-control" id="stop" placeholder="Zastávka" ref="stop" value="Slánská" required>-->
          <select class="form-select" id="stop" ref="stop" required>
            <option selected disabled>-- Vyberte zastávku --</option>
            <option v-for="item in stops">{{ item.name }}</option>
          </select>
          <label for="stop">Odkud</label>
        </div>
        <div class="col-12 col-md-5 form-floating">
          <input type="datetime-local" class="form-control" id="time" placeholder="Odjezd" ref="time" :min="this.minTime" required>
          <label for="time">Kdy</label>
        </div>
        <div class="col-12 col-md-2">
          <input type="submit" class="btn btn-primary" value="Zobrazit" @click.prevent="getFormValues()">
        </div>
      </div>
    </form>
    <h2>Odjezdy <strong>{{formatDate(departuresForm['time']) === formatDate(new Date()) ? 'v ' + formatTime(departuresForm['time']) : formatDateTime(departuresForm['time'])}}</strong> ze zastávky <strong>{{ departuresForm['stop'] }} </strong></h2>
  </div>
  <div class="card departures" v-for="item in list" :key="item.id">
    <div class="card-header" :class="!isBefore(time, item.departure_timestamp.predicted) ? ' left ' : ''">
      <div class="row">
        <div class="col-6" v-if="isBefore(time, item.departure_timestamp.predicted) && formatDate(departuresForm['time']) === formatDate(new Date())">
          za {{ formatMins(countTime(time, item.departure_timestamp.predicted)) }} min <span
            v-if="item.delay.is_available && item.delay.minutes > 0">včetně zpoždění</span>
        </div>
        <div class="col-6" v-else-if="isBefore(time, item.departure_timestamp.predicted) && formatDate(departuresForm['time']) !== formatDate(new Date())">
          {{ formatDateTime(item.departure_timestamp.predicted) }} <span
            v-if="item.delay.is_available && item.delay.minutes > 0">včetně zpoždění</span>
        </div>
        <div class="col-6" v-else-if="!isBefore(time, item.departure_timestamp.predicted) && formatDate(departuresForm['time']) === formatDate(new Date())">
          spoj odjel v {{ formatTime(item.departure_timestamp.predicted) }}
        </div>
        <div class="col-6" v-else-if="!isBefore(time, item.departure_timestamp.predicted) && formatDate(departuresForm['time']) !== formatDate(new Date())">
          spoj odjel {{ formatDateTime(item.departure_timestamp.predicted) }}
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
          <!-- TODO: ikonka typu vozidla - https://pid.cz/wp-content/uploads/system/Seznam_linek.pdf -->

          <div class="col-8 col-md-9">
            <img v-if="item.route.short_name === 'A' || item.route.short_name === 'B' || item.route.short_name === 'C'" src="/src/assets/img/line_types/metro.svg" class="lineType" title="metro" alt="metro">
            <!--          <div v-else-if="(item.route.short_name >= 1 && item.route.short_name <= 26) || item.route.short_name >= 91 && item.route.short_name <= 99">Tram</div>-->
            <img v-else-if="(item.route.short_name >= 1 && item.route.short_name <= 26) || item.route.short_name >= 91 && item.route.short_name <= 99" src="/src/assets/img/line_types/tram.svg" class="lineType" title="tram" alt="tram">
            <img v-else-if="(item.route.short_name >= 100 && item.route.short_name <= 960) || item.route.short_name === 'H1' || item.route.short_name === 'AE' || item.route.short_name === 'CYK1' || item.route.short_name === 'CYK2'" src="/src/assets/img/line_types/bus.svg" class="lineType" title="bus" alt="bus">
            <img v-else-if="item.route.short_name === 'P1' || item.route.short_name === 'P2' || item.route.short_name === 'P3' || item.route.short_name === 'P4' || item.route.short_name === 'P5' || item.route.short_name === 'P6'" src="/src/assets/img/line_types/ferry.svg" class="lineType" title="ferry" alt="ferry">
            <div v-else-if="item.route.short_name === 'LD'">Lanovka</div>
            <img v-else src="/src/assets/img/line_types/vlak.svg" class="lineType" title="vlak" alt="vlak">
            {{ item.route.short_name }} <span
              class="text-black-50">směr {{ item.trip.headsign }}</span></div>
          <div class="col-4 col-md-3 text-end">{{ formatTime(item.departure_timestamp.scheduled) }}</div>
          <div class="col-12 mt-2">
            <img v-if="item.trip.is_wheelchair_accessible" src="/src/assets/img/wheelchair-on.svg" class="tripIcon" title="nízkopodlažní" alt="wheelchair">
            <img v-if="item.trip.is_air_conditioned" src="/src/assets/img/air-on.svg" class="tripIcon" title="klimatizace pro cestující" alt="airconditon">
          </div>
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
  height: -webkit-fill-available;
}

#departuresForm .form-floating > label {
  left: unset;
  display: flex;
  align-items: center;
}

.card-title span {
  font-size: 13px;
}

.card-header {
  background-color: rgba(25, 135, 84, 15%);
}

.card-header.left {
  background-color: rgba(0, 0, 0, 3%);
}

h2 {
  margin-top: 0.5rem !important;
}

.tripIcon {
  max-height: 1.5em;
}

.lineType {
  height: 1em;
}

</style>