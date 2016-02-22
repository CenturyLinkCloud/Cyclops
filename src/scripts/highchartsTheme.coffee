Highcharts.theme = {
   colors: ["#00853f", "#8cc63f", "#43c1e6", "#f0ad4e", "#333333", "#666666", "#999999"],
   chart: {
      backgroundColor: null,
      style: {
         fontFamily: '"Open Sans", Helvetica, Arial, Sans-Serif'
      }
   },
   title: {
      style: {
         fontSize: '16px',
         fontWeight: 'normal',
         textTransform: 'uppercase',
      },
      text: ''
   },
   subtitle: {
     style: {
       fontSize: '12px',
       fontWeight: 'normal',
       textTransform: 'uppercase'
     }
   }
   tooltip: {
            headerFormat: '<span style="font-size: 10px">{point.key}</span><br/>',
            shared: true
        },
   legend: {
      enabled: false
   },
   xAxis: {
      gridLineWidth: 1,
      tickmarkPlacement: on,
      title: {
        text: null
      }
      labels: {
         style: {
            fontSize: '12px'
         }
      }
   },
   yAxis: {
      gridLineWidth: 1,
      gridLineDashStyle: 'dash',
      tickAmount: 5,
      title: {
         text: null
      },
      labels: {
         style: {
            fontSize: '12px'
         }
      }
   },
   plotOptions: {
     pie: {
       dataLabels: {
         enabled: false,
       },
       size: 300,
       colors: ["#8cc63f", "#eeeeee"],
       states: {
         hover: {
           enabled: false
         }
       },
       title: {
         style: {
           fontSize: '30px',
           colors: '#8cc63f'
         }
       }
     }
   },
   background2: '#F0F0EA',
   credits: {
            enabled: false
        },
};

Highcharts.setOptions(Highcharts.theme);
