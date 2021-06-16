<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class AddActionDateToActionlog extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::table('action_logs', function (Blueprint $table) {
            $table->datetime('action_date')->nullable()->default(null);
        });

        $prefix = DB::getTablePrefix();
        DB::update("UPDATE ${prefix}action_logs SET action_date = created_at WHERE action_date IS NULL AND action_type IN ('checkout', 'checkin from')");
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::table('action_logs', function (Blueprint $table) {
            $table->dropColumn('action_date');
        });
    }
}
