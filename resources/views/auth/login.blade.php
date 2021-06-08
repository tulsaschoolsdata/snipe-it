@extends('layouts/basic')


{{-- Page content --}}
@section('content')

    <form role="form" action="{{ url('/login') }}" method="POST" autocomplete="false">
        <input type="hidden" name="_token" value="{{ csrf_token() }}" />

        <!-- this is a hack to prevent Chrome from trying to autocomplete fields -->
        <input type="text" name="prevent_autofill" id="prevent_autofill" value="" style="display:none;" aria-hidden="true">
        <input type="password" name="password_fake" id="password_fake" value="" style="display:none;" aria-hidden="true">

        <div class="container">
            <div class="row">

                <div class="col-md-4 col-md-offset-4">

                    <div class="box login-box">
                        <div class="box-header with-border">
                            <h1 class="box-title"> {{ trans('auth/general.login_prompt')  }}</h1>
                        </div>


                        <div class="login-box-body">
                            <div class="row">

                                @if ($snipeSettings->login_note)
                                    <div class="col-md-12">
                                        <div class="alert alert-info">
                                            {!!  Parsedown::instance()->text(e($snipeSettings->login_note))  !!}
                                        </div>
                                    </div>
                                @endif

                                <!-- Notifications -->
                                @include('notifications')

                                @if ($snipeSettings->username_login_enabled)
                                <div class="col-md-12">
                                    <!-- CSRF Token -->


                                    <fieldset>

                                        <div class="form-group{{ $errors->has('username') ? ' has-error' : '' }}">
                                            <label for="username"><i class="fa fa-user" aria-hidden="true"></i> {{ trans('admin/users/table.username')  }}</label>
                                            <input class="form-control" placeholder="{{ trans('admin/users/table.username')  }}" name="username" type="text" id="username" autocomplete="off">
                                            {!! $errors->first('username', '<span class="alert-msg" aria-hidden="true"><i class="fa fa-times" aria-hidden="true"></i> :message</span>') !!}
                                        </div>
                                        <div class="form-group{{ $errors->has('password') ? ' has-error' : '' }}">
                                            <label for="password"><i class="fa fa-key" aria-hidden="true"></i> {{ trans('admin/users/table.password')  }}</label>
                                            <input class="form-control" placeholder="{{ trans('admin/users/table.password')  }}" name="password" type="password" id="password" autocomplete="off">
                                            {!! $errors->first('password', '<span class="alert-msg" aria-hidden="true"><i class="fa fa-times" aria-hidden="true"></i> :message</span>') !!}
                                        </div>
                                        <div class="checkbox">
                                            <label style="margin-left: -20px;">
                                                <input name="remember" type="checkbox" value="1" class="minimal"> {{ trans('auth/general.remember_me')  }}
                                            </label>
                                        </div>
                                    </fieldset>
                                </div> <!-- end col-md-12 -->
                                @endif

                            </div> <!-- end row -->

                            @if ($snipeSettings->saml_enabled)
                            <div class="row ">
                                <div class="col-md-12 text-right">
                                    <a href="{{ route('saml.login')  }}">{{ trans('auth/general.saml_login')  }}</a>
                                </div>
                            </div>
                            @endif
                        </div>
                        <div class="box-footer">
                            @if ($snipeSettings->username_login_enabled)
                            <button class="btn btn-lg btn-primary btn-block">{{ trans('auth/general.login')  }}</button>
                            @endif
                            @if (!$snipeSettings->graph_login_disabled)
                            <a href="/login/graph" class="btn btn-lg btn-primary btn-block">Login with Microsoft</a>
                            @endif
                        </div>
                        @if ($snipeSettings->username_login_enabled)
                        <div class="col-md-12 col-sm-12 col-xs-12 text-right" style="padding-top: 10px;">
                            @if ($snipeSettings->custom_forgot_pass_url)
                                <a href="{{ $snipeSettings->custom_forgot_pass_url  }}" rel="noopener">{{ trans('auth/general.forgot_password')  }}</a>
                            @else
                                <a href="{{ route('password.request')  }}">{{ trans('auth/general.forgot_password')  }}</a>
                            @endif


                        </div>
                        @endif
                    </div> <!-- end login box -->

                </div> <!-- col-md-4 -->

            </div> <!-- end row -->
        </div> <!-- end container -->
    </form>

@stop
