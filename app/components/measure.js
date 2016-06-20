/**
 * Created on 6/20/16.
 */


import React, { Component } from 'react';
import {
    AppRegistry,
    StyleSheet,
    Text,
    NativeModules,
    requireNativeComponent,
    DeviceEventEmitter,
    View,

    ScrollView,
    TouchableOpacity,

    AlertIOS,
    TouchableHighlight,


} from 'react-native';

//import Message from './app/views/Message'



import { AnimatedCircularProgress } from 'react-native-circular-progress';


var BatteryManager = require('NativeModules').BatteryManager;

var BP3LManager = require('NativeModules').BP3LManager



const MAX_POINTS = 300;


export default class Measure extends Component {
    constructor(props) {
        super(props);
        this.state = {
            discoveryInfo: 'Goodbye World.' ,
            connectInfo:{},
            measureInfo:{},
            status:'disconnected'
        };


    }
    discover(){
        let self =this
        let onDiscovery = function(info){
            console.log('onDiscovery',info)
            //self.setState({batteryLevel: info.level});
            //self.setState({charging: info.isPlugged});

            self.setState({
                status:'connecting',
                discoveryInfo:info
            });


            self.connect(info.address)


        }
        self._sub_discover = DeviceEventEmitter.addListener('BP3L_Discovery', onDiscovery);


        self.setState({
            status:'searching'
        });
        BP3LManager.startDiscover('',(info) => {
            //self.setState({discoveryInfo:info});

            console.log(info)
        });


        // AlertIOS.alert(
        // 	   'Sync Complete',
        // 	   'All your data are belong to us.'
        // 	  );

    }
    connect(){

        let self =this
        let oncConnect = function(info){
            // { msg: 'Connected', address: 'D05FB8418903', name: 'BP3L' }
            console.log('oncConnect',info)
            //self.setState({batteryLevel: info.level});
            //self.setState({charging: info.isPlugged});

            self.setState({
                status:'ready',
                connectInfo:info
            });

        }

        self._sub_connect = DeviceEventEmitter.addListener('BP3L_Connect', oncConnect);

        let mac = this.state && this.state.discoveryInfo.address

        BP3LManager.connectDevice('',mac,(info) => {
            //self.setState({discoveryInfo:info});

            console.log(info)
        });

    }

    startMeasure(){
        let self =this
        let onMeasure= function(info){
            console.log('onMeasure',typeof info, info)

            if(info.msg == 'MeasureDoing'){
                self.setState({
                    status:'measuring',
                    measureInfo:info
                });

            }

            if(info.msg == 'MeasureDone'){
                self.setState({
                    status:'measureDone',
                    measureInfo:info
                });

                self.showResult(info)

            }



        }
        self._sub_measure = DeviceEventEmitter.addListener('BP3L_Measure', onMeasure);

        let mac = this.state && this.state.connectInfo.address

        BP3LManager.startMeasure('',mac,(info) => {
            //self.setState({discoveryInfo:info});

            console.log(info)

        });

    }

    onAction(action){

        if(this.state.status=='disconnected'){
            this.discover()

        }

        if(this.state.status=='ready'){

            this.startMeasure()

            this.setState({
                status:'measuring',
                measureInfo:{pressure:[0]}
            });
        }

        if(this.state.status=='measureDone'){
            this.setState({
                status:'ready'
            });
        }




    }

    showResult(data) {
        let self=this
        this.props.navigator.showLightBox({
            screen: "example.LightBoxScreen",
            passProps: {
                heartrate:data.heartrate,
                
            },
            style: {
                backgroundBlur: "dark"
            }
        });
    }



    render() {
        let self =this

        //const fill = this.state.points / MAX_POINTS * 100;
        let fill=0
        if(this.state.status=='measuring'){
            let pressure = this.state.measureInfo.pressure && this.state.measureInfo.pressure[0]
            fill = pressure * 100/ MAX_POINTS
        }


        return (
            <View style={styles.container}>
                <Text style={styles.welcome}>
                    Welcome to React Native!
                </Text>


                <TouchableOpacity
                    onPress={this.onAction.bind(this)}>

                    <AnimatedCircularProgress
                        size={200}
                        width={3}
                        fill={fill}
                        tintColor="#00e0ff"
                        backgroundColor="#3d5875">


                        {
                            (fill) => {
                                if(this.state.status!='measuring'){
                                    return <Text
                                        style={styles.statusText}>
                                        {this.state.status}
                                    </Text>
                                }else {
                                    return <Text style={styles.points}>
                                        { Math.round(MAX_POINTS * fill / 100) }
                                    </Text>
                                }
                            }
                        }


                    </AnimatedCircularProgress>
                </TouchableOpacity>




                {

                    // <TouchableOpacity onPress={this.discover.bind(this)}>
                    //     <Text style={styles.button}>discover</Text>
                    // </TouchableOpacity>
                    //
                    // <TouchableOpacity onPress={this.connect.bind(this)}>
                    // <Text style={styles.button}>connect</Text>
                    // </TouchableOpacity>
                    // <TouchableOpacity onPress={this.startMeasure.bind(this)}>
                    // <Text style={styles.button}>startMeasure</Text>
                    // </TouchableOpacity>


                    // <Text style={styles.instructions}>
                    //     discoveryInfo:
                    //     {this.state.discoveryInfo.address }
                    // </Text>

                    // <Text style={styles.instructions}>
                    //     measureInfo:{this.state.measureInfo.msg=='MeasureDoing' && this.state.measureInfo.pressure[0]}
                    //     {this.state.measureInfo.msg=='Error' && this.state.measureInfo.msg}
                    // </Text>
                }



                <Text style={styles.instructions}>
                    Info:{this.state.connectInfo && this.state.connectInfo.address }
                </Text>



            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
       flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',

    //justifyContent: 'space-between',
    //backgroundColor: '#152d44',
    //padding: 50,
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
    // button: {
    //     borderRadius: 5,
    //     flex: 1,
    //     height: 20,
    //     alignSelf: 'stretch',
    //     justifyContent: 'center',
    //     overflow: 'hidden',
    // },
    button: {
        textAlign: 'center',
        fontSize: 18,
        marginBottom: 10,
        marginTop:10,
        color: 'blue'
    },
    buttonText: {
        fontSize: 18,
        margin: 5,
        textAlign: 'center',
    },


    statusText:{
        backgroundColor: 'transparent',
        position: 'absolute',
        top: 72,
        left: 56,
        width: 90,
        textAlign: 'center',
        color: '#7591af',
        fontSize: 16,
    },
    points: {
        backgroundColor: 'transparent',
        position: 'absolute',
        top: 72,
        left: 56,
        width: 90,
        textAlign: 'center',
        color: '#7591af',
        fontSize: 50,
        fontWeight: "100"
    },

    pointsDelta: {
        color: '#4c6479',
        fontSize: 50,
        fontWeight: "100"
    },
    pointsDeltaActive: {
        color: '#fff',
    }
});