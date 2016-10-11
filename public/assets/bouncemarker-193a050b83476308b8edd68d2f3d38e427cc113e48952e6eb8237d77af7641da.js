/**
 * Copyright (C) 2013 Maxime Hadjinlian <maxime.hadjinlian@gmail.com>
 * All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
!function(){var t=L.Marker.prototype.onAdd;L.Marker.mergeOptions({bounceOnAdd:!1,bounceOnAddDuration:1e3,bounceOnAddHeight:-1}),L.Marker.include({_toPoint:function(t){return this._map.latLngToContainerPoint(t)},_toLatLng:function(t){return this._map.containerPointToLatLng(t)},_animate:function(t){var n=new Date,o=setInterval(function(){var i=new Date-n,e=i/t.duration;e>1&&(e=1);var _=t.delta(e);t.step(_),1===e&&(t.end(),clearInterval(o))},t.delay||10)},_move:function(t,n){var o=L.latLng(this._orig_latlng),i=this._drop_point.y,e=this._drop_point.x,_=this._point.y-i,a=this;this._animate({delay:10,duration:n||1e3,delta:t,step:function(t){a._drop_point.y=i+_*t-(a._map.project(a._map.getCenter()).y-a._orig_map_center.y),a._drop_point.x=e-(a._map.project(a._map.getCenter()).x-a._orig_map_center.x),a.setLatLng(a._toLatLng(a._drop_point))},end:function(){a.setLatLng(o)}})},_easeOutBounce:function(t){return 1/2.75>t?7.5625*t*t:2/2.75>t?7.5625*(t-=1.5/2.75)*t+.75:2.5/2.75>t?7.5625*(t-=2.25/2.75)*t+.9375:7.5625*(t-=2.625/2.75)*t+.984375},bounce:function(t,n){this._orig_map_center=this._map.project(this._map.getCenter()),this._drop_point=this._getDropPoint(n),this._move(this._easeOutBounce,t)},_getDropPoint:function(t){this._point=this._toPoint(this._orig_latlng);var n;return n=void 0===t||0>t?this._toPoint(this._map.getBounds()._northEast).y:this._point.y-t,new L.Point(this._point.x,n)},onAdd:function(n){this._map=n,this._orig_latlng=this._latlng,this.options.bounceOnAdd===!0&&(this._drop_point=this._getDropPoint(this.options.bounceOnAddHeight),this.setLatLng(this._toLatLng(this._drop_point))),t.call(this,n),this.options.bounceOnAdd===!0&&this.bounce(this.options.bounceOnAddDuration,this.options.bounceOnAddHeight)}})}();