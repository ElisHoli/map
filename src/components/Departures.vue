<script>
import axios from "axios";
import dayjs from "dayjs";
import "dayjs/plugin/relativeTime"

const apikey = import.meta.env.VITE_API_KEY;

export default {
  name: "Departures",
  methods: {
    getFormValues() {
      if (this.$refs.stop.value !== '' && this.$refs.time.value !== '') {
        this.departuresForm['stop'] = this.$refs.stop.value
        this.departuresForm['time'] = this.$refs.time.value

        this.$refs.stop.style = "border-color: #ced4da"
        this.$refs.time.style = "border-color: #ced4da"
      } else {
        if (this.$refs.stop.value === '') {
          this.$refs.stop.style = "border-color: #dc3545"
        } else {
          this.$refs.stop.style = "border-color: #ced4da"
        }
        if (this.$refs.time.value === '') {
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
      now: '',
      vehicle: '',
      departuresForm: {stop: 'Slánská', time: dayjs().format('YYYY-MM-DD HH:mm')},
    };
  },
  created() {
    axios.defaults.headers.common['x-access-token'] = `${apikey}`

    const onNewData = () => {
      axios
          .get("https://api.golemio.cz/v2/pid/departureboards?names=" + this.departuresForm['stop'] + "&minutesBefore=1&minutesAfter=60&timeFrom=" + this.departuresForm['time'] + "&includeMetroTrains=true&mode=departures&order=real&filter=routeOnce&skip=canceled", {
            "Content-Type": "application/json",
          })
          .then(response => (
              console.log(response),
                  this.list = response.data.departures))
    }
    setInterval(onNewData, 1000)
  }
}
</script>

<template>
  <div id="departuresForm">
    <form>
      <div class="row">
        <div class="col-12 col-md-5 form-floating">
          <input type="text" class="form-control" id="stop" placeholder="Zastávka" ref="stop" value="Slánská" required>
          <label for="stop">Odkud</label>
        </div>
        <div class="col-12 col-md-5 form-floating">
          <input type="datetime-local" class="form-control" id="time" placeholder="Odjezd" ref="time" required>
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
    <div class="card-header">
      <div class="row">
        <!-- TODO: opravit časy -->
        <div class="col-6" v-if="isBefore(time, item.departure_timestamp.predicted)">
          za {{ formatMins(countTime(time, item.departure_timestamp.predicted)) }} min <span
            v-if="item.delay.is_available && item.delay.minutes > 0">včetně zpoždění</span>
        </div>
        <div class="col-6" v-else>
          spoj odjel
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
          <div class="col-8 col-md-9">{{ item.route.short_name }} <span
              class="text-black-50 ">směr {{ item.trip.headsign }}</span></div>
          <div class="col-4 col-md-3 text-end">{{ formatTime(item.departure_timestamp.scheduled) }}</div>
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

h2 {
  margin-top: 0.5rem !important;
}

</style>