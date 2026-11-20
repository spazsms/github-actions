<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/version', function () {
    return response()->json(['version' => app()->version()]);
});
