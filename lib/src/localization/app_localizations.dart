import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = {
    'en': {
      'app_title': 'Cardamom Analytics',
      'dashboard': 'Home',
      'analytics': 'Analytics',
      'history': 'History',
      'live': 'Live',
      'sync_now': 'Sync Now',
      'latest_auctions': 'Latest Auctions',
      'no_auction_active': 'No auction currently active',
      'searching_auctions': 'Searching for live auctions...',
      'live_auction_from': 'LIVE: {channel}',
      'recent_session_from': 'Recent Session: {channel}',
      'spices_board_auction': 'Spices board E-auction',
      'sbe_auction': 'Spices board E-auction',
      'quick_log': 'Quick Log',
      'enter_price': 'Enter Price',
      'log_bid': 'Log Bid',
      'live_auction_now': 'Live Auction Now',
      'session_1': 'Session 1',
      'see_all': 'See All',
      'session_2': 'Session 2',
      'latest_tag': 'LATEST',


      'avg_price': 'Avg Price',
      'lot_quantity': 'Lot Quantity',
      'kg': 'kg',
      'qty_sold': 'Qty Sold',
      'volatility_30_day': '30-Day Variability',
      'volatility_help_title': '30-Day Variability',
      'volatility_help_desc': 'Shows how much the price has moved over the last 30 auction days. Helps you see the monthly trend. Higher values indicate unpredictable prices and higher risk.',
      'stability_help_title': 'Market Stability',
      'stability_help_desc': 'Shows the typical price movement you can expect. A lower value means prices are more predictable and steady.',
      'typical_price_help_title': 'Typical Price (Median)',
      'typical_price_help_desc': 'The middle value of prices from the last 5 seasons. It is more representative of common prices than a simple average.',
      'normal_range_help_title': 'Normal Range',
      'normal_range_help_desc': 'The price range where the majority of auctions fell during the last 5 seasons.',
      'highest_seen_help_title': 'Highest Seen',
      'highest_seen_help_desc': 'The absolute highest price recorded in our dataset. These are rare occurrences.',
      'lowest_seen_help_title': 'Lowest Seen',
      'lowest_seen_help_desc': 'The absolute lowest price recorded in our dataset.',
      'got_it': 'Got it',
      'total_qty': 'Total Qty Sold',
      'qty_arrived': 'Total Qty Arrived',
      'lots': 'Total Lots',
      'market_insights': 'Market Insights',
      'price_trend': 'Price Trend',
      'price_performance': 'Price Performance',
      'volatility': 'Volatility',
      'signal': 'Signal',
      'about': 'About',
      'settings': 'Settings',
      'notifications': 'Price Update Alerts',
      'language': 'Language',
      'version': 'Version',
      'market_bullish': 'Market is Bullish',
      'market_bearish': 'Market is Bearish',
      'market_neutral': 'Market is Neutral',
      'high_volatility': 'High Volatility Detected',
      'low_volatility': 'Low Volatility (Stable)',
      'buy_signal': 'Opportunity to Buy',
      'sell_signal': 'Consider Selling',
      'hold_signal': 'Wait for clear trend',
      'market_status': 'Market Status',
      'market_advice': 'Market Advice',
      'improving': 'Improving',
      'weakening': 'Weakening',
      'stable': 'Stable',
      'sell_now': 'Good time to sell',
      'wait': 'Better to wait',
      'advice_high': 'Prices are much higher than normal. It\'s a great time to sell your stock.',
      'advice_low': 'Prices are unusually low. If you can, hold your cardamom for a better market.',
      'advice_improving': 'Prices have started moving up recently. Keep a close watch.',
      'advice_stable': 'Prices are around normal levels for this time of year.',
      'syncing': 'Syncing latest data...',
      'updated': 'Data updated!',
      'total': 'Total',
      'mean': 'Mean',
      'median': 'Median',
      'min': 'Min',
      'max': 'Max',
      'loading_data': 'Initial Data Loading...',
      'preparing_records': 'We are preparing thousands of historical records for you.',
      'force_reseed_button': 'Force Re-Seed If Stuck',
      'smart_advisory': 'Smart Advisory',
      'risk_analysis': 'Risk Analysis',
      'current_risk': 'Current Risk',
      'detailed_statistics': 'Detailed Statistics',
      'std_dev': 'Std. Deviation',
      'price_range': 'Price Range',
      'mean_price': 'Mean Price',
      'median_price': 'Median Price',
      'max_price': 'Highest Price',
      'min_price': 'Lowest Price',
      'current_season': 'Current Season',
      'market_status_label': 'Market Status',
      'confidence_note': 'Confidence Note',
      'disclaimer_text': 'These insights are based on historical auction records. Cardamom prices are subject to global market conditions, crop yield, and trade policies. Past performance is not a guarantee of future prices. Use this only for guidance.',
      'no_data_insights': 'Not enough data for insights.',
      'low': 'Low',
      'moderate': 'Moderate',
      'high': 'High',
      'no_data_range': 'No data for selected range',
      'sma_volatility_label': 'Moving Average & Volatility Bands',
      'trend_14day': 'Moving Average',
      'actual_price': 'Actual Price',
      'volatility_band': 'Volatility Band',
      'vs_last_year': 'Vs Last Year:',
      'vs_5yr_avg': '5-Year Avg:',
      'vs_long_term': 'Long Term:',
      'recent_activity': 'Recent Market Activity',
      'volatility_30day': '30-Day Volatility',
      'view_market_details': 'View Market Details',
      'historical_data': 'Historical Data',
      'force_reseed_local': 'Force Re-Seed (Local File)',
      'auction_log': 'Auction Log',
      'bold_average_disclaimer': 'Bold values are daily averages',
      'clear_all_data': 'Clear All Data',
      'no_historical_data': 'No historical data found.',
      'click_sync_hint': 'Click the sync button to get the latest data.',
      'syncing_server': 'Syncing with server...',
      'sync_complete': 'Sync complete. Added {count} new records.',
      'sync_failed': 'Sync failed:',
      'clear_data_confirm': 'Clear All Data?',
      'clear_data_desc': 'This will delete all stored auction data.',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'reseed_attempt': 'Attempting to re-seed from local file...',
      'reseed_complete': 'Re-seed completed: {count} records added.',
      'reseed_failed': 'Re-seed failed:',
      'from_date': 'From Date',
      'to_date': 'To Date',
      'weekly_momentum': 'Weekly Momentum',
      'vs_last_week': 'vs. last week',
      'weekly_range': 'Weekly Price Range',
      'market_performance': 'Market Performance',
      'momentum_explanation': 'Market Speed:',
      'momentum_desc': 'This shows if the price is growing or dropping compared to last week. Green (+) means prices are rising. Red (-) means prices are cooling down.',
      'range_explanation': 'Price Gap:',
      'range_desc': 'This shows the difference between the highest and lowest prices this week. A large gap means the market is unstable (high volatility). A small gap means the price is steady.',
      'weekly_auctions': 'Weekly Auction Summary',
      'auction_details': 'Auction Details',
      'pro_tips': 'Farmer Pro-Tips',
      'price_near_high': 'Prices are close to the 6-month high. Consider selling if your stock is ready.',
      'price_near_low': 'Prices are near the 6-month low. If you can, hold your stock for a better price.',
      'high_arrivals': 'Arrivals are higher than average today. This might put some pressure on the price.',
      'low_arrivals': 'Arrivals are lower than normal. This could lead to a small price jump soon.',
      'market_stable_tip': 'Market is very steady right now. You can take your time with selling decisions.',
      'improving_trend_tip': 'The price trend is moving up. It might be worth watching for a few more days.',
      'seasonal_high_tip': 'Historically, {month} is a strong month for prices. Consider this for your selling strategy.',
      'seasonal_low_tip': 'Historically, {month} is a weaker month for prices. Plan your stock accordingly.',
      'seasonal_next_high_tip': 'Looking ahead: {month} is historically a strong month. You might see better prices soon.',
      'seasonal_next_low_tip': 'Looking ahead: {month} is historically a weaker month. Plan your harvest/sales accordingly.',
      'compared_to_normal': 'Compared to Normal',
      'market_stability': 'Market Stability',
      'this_week': 'This Week',
      'compared_to_normal_desc': 'Current prices are about {pct}% {level} than the 11-year average for {month}.',
      'combined_comparison_desc': 'Prices are {avg_5_season_pct}% {level} than the 5-season average; today is ₹{diff_amount} {yoy_level} than the same day last year.',
      'level_higher': 'higher',
      'level_lower': 'lower',
      'steady_week': 'Prices are steady this week.',
      'volatile_week': 'Prices are volatile this week.',
      'sideways_week': 'Prices are moving sideways this week.',
      'stability_advice_steady': 'You can take time with selling decisions.',
      'stability_advice_volatile': 'Market is unpredictable; consider selling in smaller batches.',
      'stability_advice_sideways': 'No major trend; wait for clearer signals.',
      'this_week_desc': 'Prices {direction} this week ({pct}).',
      'direction_up': 'moved up',
      'direction_down': 'moved down',
      'direction_sideways': 'stayed sideways',
      'seasonal_insight_title': 'Seasonal Insight',
      'seasonal_insight_desc': 'Prices are usually stronger during {pattern}.',
      'month_1': 'January', 'month_2': 'February', 'month_3': 'March', 'month_4': 'April',
      'month_5': 'May', 'month_6': 'June', 'month_7': 'July', 'month_8': 'August',
      'month_9': 'September', 'month_10': 'October', 'month_11': 'November', 'month_12': 'December',
      'moving_average_label': '14D SMA',
      'moving_average_desc': 'Shows the 14-day trend by filtering out daily price noise.',
      'volatility_bands_label': '2σ Bands',
      'volatility_bands_desc': 'Statistical range (2-sigma) where most prices occur. Wide = High Risk.',
      'actual_label': 'Actual',
      'sma_14_label': 'SMA (14)',
      'key_statistics': 'Key Statistics',
      'price_level_title': 'Price Level',
      'price_level_help_title': 'Price Level',
      'price_level_help_desc': 'Shows the average price trend across the last five harvest seasons to help you identify long-term market value.',
      'historical_label': 'Historical',
      'typical_price_label': 'Typical Price (Median)',
      'normal_range_label': 'Normal Range',
      'highest_lowest_title': 'Highest & Lowest',
      'ten_years_label': 'Historical',
      'highest_seen_label': 'Highest Seen',
      'lowest_seen_label': 'Lowest Seen',
      'rare_label': 'Rare',
      'price_stability_title': 'Price Stability',
      'stability_level_label': 'Stability Level',
      'price_spread_title': 'Price Spread',
      'very_wide_label': 'Very Wide',
      'narrow_label': 'Narrow',
      'distance_label': 'Distance between lowest and highest prices',
      'key_insight_title': 'Key Insight',
      'what_this_means_title': 'What this means',
      'years_of_data': '{count} Years of Data',
      'months_of_data': '{count} Months of Data',
      'last_three_seasons': 'Last 5 Seasons',
      'normal_range_seasonal': 'Normal Range (5 Seasons)',
      'range_shown': 'Data spanning {range}',
      'highest_in_range': 'Peak Value',
      'lowest_in_range': 'Period Floor',
      'above_average': 'Trading above the historical baseline',
      'below_average': 'Trading below the historical baseline',
      'yesterday': 'Yesterday',
      'today': 'Today',
      'price_movement': 'Price Movement',
      'feedback': 'Feedback',
      'feedback_hint': 'Tell us how we can improve...',
      'name_optional': 'Name (Optional)',
      'email_optional': 'Email (Optional)',
      'send_feedback': 'Send Feedback',
      'feedback_success': 'Thank you for your feedback!',
      'feedback_empty_error': 'Please enter some feedback',
      'feedback_desc': 'Your feedback helps us make this app better for the farmer community.',
      'export_data': 'Export to Excel',
      'weekly_market_snapshot': 'Weekly Market Snapshot',
      'this_week_snapshot': 'This week:',
      'up_from_last_week': 'Up from last week',
      'down_from_last_week': 'Down from last week',
      'avg_price_label': 'Avg Price',
      'today_price_label': 'Today:',
      'trading_near_high': 'Prices are trading near the weekly high',
      'trading_near_low': 'Prices are trading near the weekly low',
      'trading_near_mid': 'Prices are trading near the weekly middle',
      'weekly_volatility_label': 'Weekly volatility:',
      'volatility_low': 'LOW',
      'volatility_moderate': 'MODERATE',
      'volatility_high': 'HIGH',
      'market_speed': 'Market Speed',
      'daily_range': 'Daily Range',
      'market_verdict': 'Market Verdict',
      'research_hub': 'Research Hub',
      'arrivals_insight': 'Market Arrivals',
      'arrivals_desc': 'Supply Trend',
      'export_demand': 'Export Demand',
      'export_desc': 'Global Signal',
      'seasonal_trends': 'Seasonal Trends',
      'seasonal_desc': 'Historical Heatmap',
      'stable_supply': 'Stable Supply',
      'strong_demand': 'Strong Demand',
      'weak_demand': 'Weak Demand',
      'volatile': 'Volatile',
      'peak_month': 'Peak Month',
      'off_month': 'Off-season Month',
      'arrivals_help_text': 'Market Arrivals comparison vs 4-week average shows if supply is tightening or surging.',
      'demand_help_text': 'Demand Resilience index based on the ability of prices to hold steady against arrival volumes.',
      'seasonal_help_text': 'Historical profitability heatmap for the current month across 8+ years of auction data.',
      'weekly_range_help': 'This indicates the variation between the lowest and highest prices observed during successful auctions this week.',
      'weekly_momentum_help': 'Momentum represents the percentage change in the average price compared to the previous 7-day period.',
      'weekly_volatility_help': 'Weekly Volatility measures the average daily price variation. High volatility indicates higher market uncertainty and risk.',
      'tap_for_details': 'Tap for details',
      'close': 'Close',
      'market_strong': 'Prices are rising',
      'market_steady': 'Prices are steady',
      'market_weakened': 'Prices are slightly lower',
      'up_by_rupee': 'Up by ₹{amount}',
      'down_by_rupee': 'Down by ₹{amount}',
      'action_label': 'Decision:',
      'good_time_to_sell': 'Good time to sell',
      'wait_for_clear_trend': 'Wait for clear trend',
      'be_cautious': 'Be cautious',
      'market_risk_details_title': 'Detailed Market Risk (Advanced)',
      'risk_low': 'Low Risk',
      'risk_moderate': 'Moderate Risk',
      'risk_high': 'High Risk',
      'verdict_explanation_normal': 'Prices are around normal levels. Waiting may give better clarity.',
      'average_disclaimer': 'Data reflects daily average market values.',
      'analytics_disclaimer': 'All calculations are based on daily auction averages.',
      'last_updated_label': 'Last updated: {time}',
      'export_success': 'Excel file exported successfully!',
      'select_language': 'Select Language',
      'email': 'Email Address',
      'phone_number': 'Phone Number',
      'profile_privacy_note': 'Your details are stored locally on this device.',
      'initial_sync_pending': 'Fetching today\'s latest records...',
      'initial_sync_hint': 'You are currently seeing historical data. Please wait or press refresh for today\'s live prices.',
      'short_term': 'Short-term',
      'long_term': 'Long-term',
      'exceptional_years': 'Exceptional years only',
      'market_risk_stability': 'Market Risk & Stability',
      'confidence_high': 'Confidence: High',
      'confidence_medium': 'Confidence: Medium',
      'confidence_low': 'Confidence: Low',
      'why_label': 'Why',
      'decision_summary': 'Market Summary',
      'sell': 'Sell',
      'hold': 'Hold',
      'wait_label': 'Wait',
      'yes': 'YES',
      'no': 'NO',
      'risk': 'Risk',
      'typical_movement': 'Typical movement:',
      'price_moves_context': 'Price moves ± {value} from typical price',
      'full_history_label': 'Full {count} Years History',
      'data_range': 'Data Range',
      'no_seasonal_data': 'Historical seasonal data is being analyzed...',
      'error_loading_analytics': 'Error loading analytics',
      'profile': 'Profile',
      'user_name': 'Your Name',
      'farm_name': 'Farm/Estate Name',
      'location': 'Location',
      'save_profile': 'Save Profile',
      'next_scheduled_auctions': 'Next Scheduled Auctions',
      'morning_session': 'Morning Session',
      'afternoon_session': 'Afternoon Session',
      'morning_session_time': '9:30 AM',
      'afternoon_session_time': '2:15 PM',
      'live_auction_title': 'LIVE: Spices Board Auction',
      'market_pulse': 'Market Pulse',
      'live_tracking_desc': 'Live tracking for Spices Board auctions is active. Track bids as they happen.',
      'current_bid': 'CURRENT BID',
      'watch_now': 'Watch Now',
      'tap_live_tab_hint': 'Tap "Live" tab to view feed',
      'auctioneer_label': 'Auctioneer',
      'time_label': 'Time',
      'location_label': 'Location',
      'auction_no_label': 'Auction Number',
      'date_label': 'Date',
      'live_auction_schedule_hint': 'Live auctions typically occur Monday through Saturday, 9:00 AM - 8:00 PM.',
      'try_discovery_again': 'Try Discovery Again',
      'risk_msg_low': 'Market is very stable. Good time for slow decisions.',
      'risk_msg_moderate': 'Normal market movements detected. Stay alert.',
      'risk_msg_high': 'Prices are swinging wildly. Be very careful with large stock.',
      'notification_denied': 'Notification permissions denied.',
      'ok': 'OK',
      'could_not_open_email': 'Could not open email app.',
      'register_sync_cloud': 'Register & Sync to Cloud',
      'range_1m': '1M',
      'range_6m': '6M',
      'range_1y': '1Y',
      'range_all': '5Y',
      'advisory_support_line': 'Based on seasonal patterns and recent price movement.',
      'chart_explanation_sentence': 'See how the market price moves over time compared to normal levels.',
      'more_insights': 'More insights',
    },
    'ml': {
      'app_title': 'ഏലക്കായ അനലിറ്റിക്സ്',
      'dashboard': 'ഹോം',
      'analytics': 'വിശകലനം',
      'history': 'ചരിത്രം',
      'live': 'ലൈവ്',
      'sync_now': 'സിങ്ക് ചെയ്യുക',
      'latest_auctions': 'പുതിയ ലേലങ്ങൾ',
      'no_auction_active': 'നിലവിൽ ലേലങ്ങൾ ഒന്നുമില്ല',
      'searching_auctions': 'ലൈവ് ലേലങ്ങൾക്കായി തിരയുന്നു...',
      'live_auction_from': 'ലൈവ്: {channel}',
      'recent_session_from': 'കഴിഞ്ഞ സെഷൻ: {channel}',
      'spices_board_auction': 'സ്പൈസസ് ബോർഡ് ഇ-ലേലം',
      'sbe_auction': 'സ്പൈസസ് ബോർഡ് ഇ-ലേലം',
      'quick_log': 'ക്വിക്ക് ലോഗ്',
      'enter_price': 'വില നൽകുക',
      'log_bid': 'രേഖപ്പെടുത്തുക',
      'live_auction_now': 'ലേലം ഇപ്പോൾ തത്സമയം',
      'session_1': 'സെഷൻ 1',
      'see_all': 'എല്ലാം കാണുക',
      'session_2': 'സെഷൻ 2',
      'latest_tag': 'ഏറ്റവും പുതിയത്',


      'avg_price': 'ശരാശരി വില',
      'lot_quantity': 'മൊത്തം അളവ്',
      'kg': 'കിലോ',
      'qty_sold': 'വിൽപ്പന അളവ്',
      'total_qty': 'ആകെ വിൽപ്പന അളവ്',
      'qty_arrived': 'ആകെ എത്തിയ അളവ്',
      'lots': 'ആകെ ലോട്ടുകൾ',
      'volatility_30_day': '30-ദിവസത്തെ വ്യതിയാനം (Variability)',
      'volatility_help_title': '30-ദിവസത്തെ വ്യതിയാനം',
      'volatility_help_desc': 'കഴിഞ്ഞ 30 ലേല ദിവസങ്ങളിൽ വിലയിലുണ്ടായ മാറ്റം കാണിക്കുന്നു. പ്രതിമാസ പ്രവണത മനസ്സിലാക്കാൻ ഇത് സഹായിക്കുന്നു.',
      'stability_help_title': 'വിപണി സ്ഥിരത',
      'stability_help_desc': 'പ്രതീക്ഷിക്കാവുന്ന സാധാരണ വില വ്യതിയാനം കാണിക്കുന്നു. താഴ്ന്ന മൂല്യം എന്നാൽ വില കൂടുതൽ സ്ഥിരതയുള്ളതാണ്.',
      'typical_price_help_title': 'സാധാരണ വില (മീഡിയൻ)',
      'typical_price_help_desc': 'കഴിഞ്ഞ 5 കാലങ്ങളിലെ വിലകളുടെ മധ്യത്തിലുള്ള വിലയാണിത്. വെറും ശരാശരിയേക്കാൾ കൃത്യമായ ചിത്രം ഇത് നൽകുന്നു.',
      'normal_range_help_title': 'സാധാരണ വിലയുടെ പരിധി',
      'normal_range_help_desc': 'കഴിഞ്ഞ 5 കാലങ്ങളിൽ മിക്കപ്പോഴും വിലകൾ നിന്നിരുന്ന പരിധിയാണിത്.',
      'highest_seen_help_title': 'ഏറ്റവും കൂടിയ വില',
      'highest_seen_help_desc': 'ചരിത്രപരമായ രേഖകളിൽ കാണപ്പെട്ട ഏറ്റവും ഉയർന്ന വിലയാണിത്. ഇത് അപൂർവ്വമായി മാത്രം സംഭവിക്കുന്നതാണ്.',
      'lowest_seen_help_title': 'ഏറ്റവും കുറഞ്ഞ വില',
      'lowest_seen_help_desc': 'ചരിത്രപരമായ രേഖകളിൽ കാണപ്പെട്ട ഏറ്റവും കുറഞ്ഞ വിലയാണിത്.',
      'got_it': 'ശരി',
      'market_insights': 'വിപണി വിശകലനം',
      'price_trend': 'വില വ്യതിയാനം',
      'price_performance': 'വില പ്രകടനം',
      'volatility': 'അസ്ഥിരത',
      'signal': 'സൂചന',
      'about': 'വിവരങ്ങൾ',
      'settings': 'സജ്ജീകരണങ്ങൾ',
      'notifications': 'വില അറിയിപ്പുകൾ',
      'language': 'ഭാഷ',
      'version': 'പതിപ്പ്',
      'market_bullish': 'വിപണി കുതിപ്പിലാണ്',
      'market_bearish': 'വിപണി ഇടിവിലാണ്',
      'market_neutral': 'വിപണി ശാന്തമാണ്',
      'high_volatility': 'ഉയർന്ന വില വ്യതിയാനം',
      'low_volatility': 'സ്ഥിരമായ വില',
      'buy_signal': 'വാങ്ങാൻ അനുയോജ്യമായ സമയം',
      'sell_signal': 'വിൽക്കാൻ ആലോചിക്കാം',
      'hold_signal': 'നിലവിലെ സാഹചര്യം തുടരട്ടെ',
      'market_status': 'വിപണി നില',
      'market_advice': 'നിർദ്ദേശം',
      'improving': 'മെച്ചപ്പെടുന്നു',
      'weakening': 'കുറയുന്നു',
      'stable': 'കുഴപ്പമില്ല',
      'sell_now': 'വിൽക്കാൻ നല്ല സമയം',
      'wait': 'കാത്തിരിക്കുന്നതാണ് നല്ലത്',
      'advice_high': 'വില സാധാരണയേക്കാൾ വളരെ കൂടുതലാണ്. നിങ്ങളുടെ സ്റ്റോക്ക് വിൽക്കാൻ ഇത് നല്ല സമയമാണ്.',
      'advice_low': 'വില സാരമായി കുറഞ്ഞിരിക്കുകയാണ്. സാധ്യമെങ്കിൽ കുറച്ചുകൂടി കാത്തിരിക്കുക.',
      'advice_improving': 'വില പതുക്കെ കൂടിത്തുടങ്ങിയിട്ടുണ്ട്. ശ്രദ്ധിക്കുക.',
      'advice_stable': 'വില സാധാരണ നിലയിലാണ്.',
      'syncing': 'പുതിയ വിവരങ്ങൾ ശേഖരിക്കുന്നു...',
      'updated': 'വിവരങ്ങൾ പുതുക്കി!',
      'total': 'ആകെ',
      'mean': 'ശരാശരി',
      'median': 'മധ്യം',
      'min': 'കുറഞ്ഞത്',
      'max': 'കൂടിയത്',
      'loading_data': 'വിവരങ്ങൾ ശേഖരിക്കുന്നു...',
      'preparing_records': 'ആയിരക്കണക്കിന് പഴയ വിവരങ്ങൾ ഞങ്ങൾ തയ്യാറാക്കുകയാണ്.',
      'force_reseed_button': 'ശരിയായില്ലെങ്കിൽ ഇത് അമർത്തുക',
      'smart_advisory': 'വിദഗ്ദ്ധ നിർദ്ദേശം',
      'risk_analysis': 'സാദ്ധ്യതാ വിശകലനം',
      'current_risk': 'നിലവിലെ സാഹചര്യം',
      'detailed_statistics': 'വിശദമായ കണക്കുകൾ',
      'std_dev': 'വില വ്യതിയാനം (Std Dev)',
      'price_range': 'വില പരിധി',
      'mean_price': 'ശരാശരി വില',
      'median_price': 'ഇടത്തരം വില',
      'max_price': 'ഏറ്റവും ഉയർന്ന വില',
      'min_price': 'ഏറ്റവും കുറഞ്ഞ വില',
      'current_season': 'നിലവിലെ സീസൺ',
      'market_status_label': 'വിപണി നില',
      'confidence_note': 'ശ്രദ്ധിക്കുക',
      'disclaimer_text': 'ഈ വിവരങ്ങൾ പഴയ ലേലക്കണക്കുകളെ അടിസ്ഥാനമാക്കിയുള്ളതാണ്. ഏലക്കായ വില ആഗോള വിപണി, വിളവ്, വ്യാപാര നയങ്ങൾ എന്നിവയ്ക്ക് വിധേയമാണ്. മുൻകാലങ്ങളിലെ പ്രകടനം ഭാവി വിലയുടെ ഉറപ്പല്ല. ഇത് ഒരു വഴികാട്ടിയായി മാത്രം ഉപയോഗിക്കുക.',
      'no_data_insights': 'വിവരങ്ങൾ ലഭ്യമല്ല.',
      'low': 'കുറഞ്ഞത്',
      'high': 'കൂടിയത്',
      'no_data_range': 'തിരഞ്ഞെടുത്ത കാലയളവിൽ വിവരങ്ങൾ ലഭ്യമല്ല',
      'sma_volatility_label': 'ശരാശരി വിലയും വ്യതിയാന പരിധിയും',
      'trend_14day': '14-ദിവസത്തെ ശരാശരി',
      'actual_price': 'യഥാർത്ഥ വില',
      'volatility_band': 'വ്യതിയാന പരിധി',
      'vs_last_year': 'കഴിഞ്ഞ വർഷത്തെ അപേക്ഷിച്ച്:',
      'vs_5yr_avg': '5-വർഷത്തെ ശരാശരി:',
      'vs_long_term': 'ദീർഘകാല ശരാശരി:',
      'recent_activity': 'സമീപകാല വിപണി ചലനങ്ങൾ',
      'volatility_30day': '30-ദിവസത്തെ അസ്ഥിരത',
      'view_market_details': 'വിശദാംശങ്ങൾ കാണുക',
      'historical_data': 'ചരിത്രപരമായ വിവരങ്ങൾ',
      'force_reseed_local': 'പഴയ വിവരങ്ങൾ വീണ്ടും ചേർക്കുക (Local File)',
      'auction_log': 'ലേല വിവരങ്ങൾ',
      'bold_average_disclaimer': 'ബോൾഡ് അക്ഷരത്തിലുള്ളവ ശരാശരി വിലയാണ്',
      'clear_all_data': 'എല്ലാ വിവരങ്ങളും നീക്കം ചെയ്യുക',
      'no_historical_data': 'വിവരങ്ങൾ ഒന്നും ലഭ്യമല്ല.',
      'click_sync_hint': 'പുതിയ വിവരങ്ങൾ ലഭിക്കാൻ സിങ്ക് ബട്ടൺ അമർത്തുക.',
      'syncing_server': 'സെർവറിൽ നിന്ന് വിവരങ്ങൾ ശേഖരിക്കുന്നു...',
      'sync_complete': 'സിങ്ക് പൂർത്തിയായി. {count} പുതിയ വിവരങ്ങൾ ചേർത്തു.',
      'sync_failed': 'സിങ്ക് പരാജയപ്പെട്ടു:',
      'clear_data_confirm': 'എല്ലാ വിവരങ്ങളും നീക്കം ചെയ്യണോ?',
      'clear_data_desc': 'ഇത് നിലവിലുള്ള എല്ലാ ലേല വിവരങ്ങളും ഡിലീറ്റ് ചെയ്യും.',
      'cancel': 'റദ്ദാക്കുക',
      'clear': 'ഡിലീറ്റ്',
      'reseed_attempt': 'ലോക്കൽ ഫയലിൽ നിന്ന് വിവരങ്ങൾ ചേർക്കാൻ ശ്രമിക്കുന്നു...',
      'reseed_complete': 'പൂർത്തിയായി: {count} വിവരങ്ങൾ ചേർത്തു.',
      'reseed_failed': 'പരാജയപ്പെട്ടു:',
      'from_date': 'തുടങ്ങുന്ന തീയതി',
      'to_date': 'അവസാന തീയതി',
      'weekly_momentum': 'പ്രതിവാര മാറ്റം',
      'vs_last_week': 'കഴിഞ്ഞ ആഴ്ചയെ അപേക്ഷിച്ച്',
      'weekly_range': 'പ്രതിവാര വില വ്യത്യാസം',
      'market_performance': 'മാർക്കറ്റ് പ്രകടനം',
      'momentum_explanation': 'മാർക്കറ്റ് വേഗത:',
      'momentum_desc': 'കഴിഞ്ഞ ആഴ്ചയെ അപേക്ഷിച്ച് വില കൂടുകയാണോ കുറയുകയാണോ എന്ന് ഇത് കാണിക്കുന്നു. പച്ച (+) എന്നാൽ വില കൂടുന്നു, ചുവപ്പ് (-) എന്നാൽ വില കുറയുന്നു എന്നാണ് അർത്ഥം.',
      'range_explanation': 'പ്രതിവാര വ്യത്യാസം:',
      'range_desc': 'ഈ ആഴ്ചയിലെ ഏറ്റവും കൂടിയ വിലയും കുറഞ്ഞ വിലയും തമ്മിലുള്ള വ്യത്യാസം ഇത് കാണിക്കുന്നു. വലിയ വ്യത്യാസം എന്നാൽ വിപണിയിൽ വലിയ മാറ്റങ്ങൾ (Volatility) ഉണ്ടെന്നാണ് അർത്ഥം.',
      'weekly_auctions': 'കഴിഞ്ഞ ഒരാഴ്ചത്തെ ലേലം',
      'auction_details': 'ലേലം വിവരങ്ങൾ',
      'pro_tips': 'കർഷകർക്കുള്ള നിർദ്ദേശങ്ങൾ',
      'price_near_high': 'വില കഴിഞ്ഞ 6 മാസത്തെ ഏറ്റവും ഉയർന്ന നിരക്കിന് അടുത്താണ്. സ്റ്റോക്ക് ഉണ്ടെങ്കിൽ വിൽക്കാൻ ആലോചിക്കാം.',
      'price_near_low': 'വില കഴിഞ്ഞ 6 മാസത്തെ ഏറ്റവും കുറഞ്ഞ നിരക്കിന് അടുത്താണ്. സാധിക്കുമെങ്കിൽ കുറച്ചുകൂടി കാത്തിരിക്കുക.',
      'high_arrivals': 'ഇന്ന് വിപണിയിൽ ഏലക്കായയുടെ വരവ് കൂടുതലാണ്. ഇത് വില അല്പം കുറയാൻ കാരണമായേക്കാം.',
      'low_arrivals': 'വിപണിയിൽ വരവ് കുറവാണ്. ഇത് വില അല്പം കൂടാൻ സഹായകരമായേക്കാം.',
      'market_stable_tip': 'വിപണി ഇപ്പോൾ വളരെ സ്ഥിരതയുള്ളതാണ്. തീരുമാനങ്ങൾ എടുക്കാൻ ധൃതി വേണ്ട.',
      'improving_trend_tip': 'വില കൂടാനുള്ള പ്രവണത വിപണിയിൽ കാണുന്നുണ്ട്. കുറച്ച് ദിവസങ്ങൾ കൂടി ശ്രദ്ധിക്കുന്നത് നന്നായിരിക്കും.',
      'seasonal_high_tip': 'ചരിത്രപരമായി, {month} മാസത്തിൽ വില വർദ്ധിക്കാൻ സാധ്യതയുണ്ട്. മികച്ച വിൽപனയ്ക്കായി ഇത് ശ്രദ്ധിക്കുക.',
      'seasonal_low_tip': 'ചരിത്രപരമായി, {month} മാസത്തിൽ വില കുറയാൻ സാധ്യതയുണ്ട്. ഇതുകൂടി കണക്കിലെടുത്ത് തീരുമാനമെടുക്കുക.',
      'seasonal_next_high_tip': 'വരാനിരിക്കുന്ന {month} മാസത്തിൽ ചരിത്രപരമായി വില കൂടാൻ സാധ്യതയുണ്ട്. മികച്ച ലാഭത്തിനായി തയ്യാറെടുക്കാം.',
      'seasonal_next_low_tip': 'വരാനിരിക്കുന്ന {month} മാസത്തിൽ ചരിത്രപരമായി വില കുറയാൻ സാധ്യതയുണ്ട്. വിൽപ്പനകൾ ഇപ്പോൾ തന്നെ ആലോചിക്കുന്നത് നന്നായിരിക്കും.',
      'compared_to_normal': 'സാധാരണ നിലയുമായുള്ള താരതമ്യം',
      'market_stability': 'വിപണി സ്ഥിരത',
      'this_week': 'ഈ ആഴ്ച',
      'compared_to_normal_desc': 'ഇപ്പോഴത്തെ വില {month}-ലെ 11 വർഷത്തെ ശരാശരിയേക്കാൾ {pct}% {level} ആണ്.',
      'combined_comparison_desc': 'വില കഴിഞ്ഞ 5 സീസണുകളിലെ ശരാശരിയേക്കാൾ {avg_5_season_pct}% {level} ആണ്; കഴിഞ്ഞ വർഷം ഇതേ ദിവസത്തേക്കാൾ ഇന്ന് ₹{diff_amount} {yoy_level} ആണ്.',
      'level_higher': 'കൂടുതൽ',
      'level_lower': 'കുറവ്',
      'steady_week': 'ഈ ആഴ്ച വില വളരെ സ്ഥിരതയുള്ളതാണ്.',
      'volatile_week': 'വിപണിയിൽ ഈ ആഴ്ച വലിയ വിലമാറ്റങ്ങൾ സംഭവിക്കുന്നു.',
      'sideways_week': 'വിലയിൽ കാര്യമായ മാറ്റങ്ങൾ ഈ ആഴ്ച പ്രകടമല്ല.',
      'stability_advice_steady': 'തീരുമാനങ്ങൾ എടുക്കാൻ ധൃതി വേണ്ട.',
      'stability_advice_volatile': 'വിപണി അസ്ഥിരമാണ്; ചെറിയ തോതിൽ വിൽക്കുന്നത് ആലോചിക്കുക.',
      'stability_advice_sideways': 'വില മാറ്റങ്ങൾ ശ്രദ്ധിച്ചു മാത്രം മുന്നോട്ട് നീങ്ങുക.',
      'this_week_desc': 'ഈ ആഴ്ച വില {direction} ({pct}).',
      'direction_up': 'വർദ്ധിച്ചു',
      'direction_down': 'കുറഞ്ഞു',
      'direction_sideways': 'കാര്യമായ മാറ്റമില്ലാതെ തുടർന്നു',
      'seasonal_insight_title': 'സീസണൽ അവലോകനം',
      'seasonal_insight_desc': 'സാധാരണയായി {pattern} മാസങ്ങളിൽ വില വർദ്ധിച്ചു കാണാറുണ്ട്.',
      'month_1': 'ജനുവരി', 'month_2': 'ഫെബ്രുവരി', 'month_3': 'മാർച്ച്', 'month_4': 'ഏപ്രിൽ',
      'month_5': 'മേയ്', 'month_6': 'ജൂൺ', 'month_7': 'ജൂലൈ', 'month_8': 'ഓഗസ്റ്റ്',
      'month_9': 'സെപ്റ്റംബർ', 'month_10': 'ഒക്ടോബർ', 'month_11': 'നവംബർ', 'month_12': 'ഡിസംബർ',
      'moving_average_label': '14D SMA',
      'moving_average_desc': 'ദിവസേനയുള്ള മാറ്റങ്ങൾ ഒഴിവാക്കി 14-ദിവസത്തെ യഥാർത്ഥ വിപണി ദിശ കാണിക്കുന്നു.',
      'volatility_bands_label': '2σ ബാൻഡുകൾ',
      'volatility_bands_desc': 'വില സാധാരണയായി നിലനിൽക്കുന്ന പരിധി (2-സിഗ്മ). വിസ്താരം കൂടിയാൽ വലിയ മാറ്റങ്ങൾ ഉണ്ടാകാം.',
      'actual_label': 'യഥാർത്ഥ വില',
      'sma_14_label': 'ശരാശരി (14)',
      'key_statistics': 'പ്രധാന വിവരങ്ങൾ',
      'price_level_title': 'വില നിലവാരം',
      'price_level_help_title': 'വില നിലവാരം',
      'price_level_help_desc': 'കഴിഞ്ഞ അഞ്ച് വിളവെടുപ്പ് സീസണുകളിലെ ശരാശരി വിലയിലെ മാറ്റങ്ങൾ കാണിക്കുന്നു.',
      'historical_label': 'ചരിത്രപരം',
      'typical_price_label': 'സാധാരണ വില (മീഡിയൻ)',
      'normal_range_label': 'സാധാരണ പരിധി',
      'highest_lowest_title': 'കൂടിയതും കുറഞ്ഞതും',
      'ten_years_label': 'ചരിത്രപരം',
      'highest_seen_label': 'ഏറ്റവും കൂടിയത്',
      'lowest_seen_label': 'ഏറ്റവും കുറഞ്ഞത്',
      'rare_label': 'അപൂർവ്വം',
      'price_stability_title': 'വില സ്ഥിരത',
      'stability_level_label': 'സ്ഥിരത നിലവാരം',
      'price_spread_title': 'വിലയിലെ വ്യത്യാസം',
      'very_wide_label': 'വളരെ കൂടുതൽ',
      'narrow_label': 'കുറവ്',
      'distance_label': 'ഏറ്റവും കൂടിയതും കുറഞ്ഞതും തമ്മിലുള്ള വ്യത്യാസം',
      'key_insight_title': 'പ്രധാന നിരീക്ഷണം',
      'what_this_means_title': 'ഇതിന്റെ അർത്ഥം',
      'years_of_data': '{count} വർഷത്തെ ഡാറ്റ',
      'months_of_data': '{count} മാസത്തെ ഡാറ്റ',
      'last_three_seasons': 'അവസാന 5 സീസണുകൾ',
      'normal_range_seasonal': 'സാധാരണ നിലവാരം (5 വർഷം)',
      'highest_in_range': 'ഉയർന്ന നിലവാരം',
      'lowest_in_range': 'കുറഞ്ഞ നിലവാരം',
      'range_shown': '{range}-ലെ വിവരങ്ങൾ',
      'above_average': 'ചരിത്രപരമായ ശരാശരിയേക്കാൾ കൂടുതലാണ്',
      'below_average': 'ചരിത്രപരമായ ശരാശരിയേക്കാൾ താഴെയാണ്',
      'yesterday': 'ഇന്നലെ',
      'today': 'ഇന്ന്',
      'price_movement': 'വില വ്യതിയാനം',
      'feedback': 'അഭിപ്രായങ്ങൾ',
      'feedback_hint': 'ഈ ആപ്പ് മെച്ചപ്പെടുത്താൻ നിങ്ങളുടെ അഭിപ്രായങ്ങൾ അറിയിക്കുക...',
      'name_optional': 'പേര് (നിർബന്ധമില്ല)',
      'email_optional': 'ഇമെയിൽ (നിർബന്ധമില്ല)',
      'send_feedback': 'അഭിപ്രായം അയക്കുക',
      'feedback_success': 'നിങ്ങളുടെ അഭിപ്രായത്തിന് നന്ദി!',
      'feedback_empty_error': 'ദയവായി നിങ്ങളുടെ അഭിപ്രായം രേഖപ്പെടുത്തുക',
      'feedback_desc': 'കർഷകർക്കായി ഈ ആപ്പ് കൂടുതൽ മെച്ചപ്പെടുത്താൻ നിങ്ങളുടെ ഓരോ അഭിപ്രായവും വിലപ്പെട്ടതാണ്.',
      'export_data': 'എക്സെൽ ഫയൽ ആക്കുക',
      'export_success': 'എക്സെൽ ഫയൽ വിജയകരമായി തയ്യാറാക്കി!',
      'select_language': 'ഭാഷ തിരഞ്ഞെടുക്കുക',
      'email': 'ഇമെയിൽ വിലാസം',
      'phone_number': 'ഫോൺ നമ്പർ',
      'profile_privacy_note': 'നിങ്ങളുടെ വിവരങ്ങൾ ഈ ഉപകരണത്തിൽ മാത്രമാണ് സൂക്ഷിക്കുന്നത്.',
      'weekly_market_snapshot': 'വാരഫലം (Weekly Snapshot)',
      'this_week_snapshot': 'ഈ ആഴ്ച:',
      'up_from_last_week': 'കഴിഞ്ഞ ആഴ്ചയേക്കാൾ കൂടുതൽ',
      'down_from_last_week': 'കഴിഞ്ഞ ആഴ്ചയേക്കാൾ കുറവ്',
      'avg_price_label': 'ശരാശരി വില',
      'today_price_label': 'ഇന്ന്:',
      'trading_near_high': 'വിലകൾ ആഴ്ചയിലെ ഏറ്റവും ഉയർന്ന നിലയിലാണ്',
      'trading_near_low': 'വിലകൾ ആഴ്ചയിലെ ഏറ്റവും താഴ്ന്ന നിലയിലാണ്',
      'trading_near_mid': 'വിലകൾ ആഴ്ചയിലെ മധ്യനിലയിലാണ്',
      'weekly_volatility_label': 'പ്രതിവാര വ്യതിയാനം:',
      'volatility_low': 'കുറവ്',
      'volatility_moderate': 'മിതമായത്',
      'volatility_high': 'കൂടിയത്',
      'initial_sync_pending': 'ഇന്നത്തെ പുതിയ വിവരങ്ങൾ ശേഖരിക്കുന്നു...',
      'initial_sync_hint': 'പുതിയ വിവരങ്ങൾ ശേഖരിക്കുന്നു... ദയവായി കാത്തിരിക്കുക.',
      'short_term': 'ഹ്രസ്വകാല',
      'long_term': 'ദീർഘകാല',
      'exceptional_years': 'അസാധാരണ വർഷങ്ങൾ മാത്രം',
      'market_risk_stability': 'വിപണി സാദ്ധ്യതയും സ്ഥിരതയും',
      'confidence_high': 'വിശ്വാസ്യത: വളരെ കൂടുതൽ',
      'confidence_medium': 'വിശ്വാസ്യത: ഇടത്തരം',
      'confidence_low': 'വിശ്വാസ്യത: കുറവ്',
      'why_label': 'എന്തുകൊണ്ട്',
      'decision_summary': 'വിപണി സംഗ്രഹം',
      'market_verdict': 'വിപണി വിധി',
      'research_hub': 'റിസർച്ച് ഹബ്',
      'arrivals_insight': 'മാർക്കറ്റ് വരവ്',
      'arrivals_desc': 'സപ്ലൈ ട്രെൻഡ്',
      'export_demand': 'കയറ്റുമതി ഡിമാൻഡ്',
      'export_desc': 'ഗ്ലോബൽ സിഗ്നൽ',
      'seasonal_trends': 'സീസണൽ ട്രെൻഡുകൾ',
      'seasonal_desc': 'ഹിസ്റ്റോറിക്കൽ ഹീറ്റ്മാപ്പ്',
      'stable_supply': 'സ്ഥിരമായ സപ്ലൈ',
      'strong_demand': 'ശക്തമായ ഡിമാൻഡ്',
      'weak_demand': 'കുറഞ്ഞ ഡിമാൻഡ്',
      'volatile': 'അസ്ഥിരമാണ്',
      'moderate': 'മിതമാണ്',
      'peak_month': 'പീക്ക് മാസം',
      'off_month': 'ഓഫ്-സീസൺ മാസം',
      'arrivals_help_text': 'വരവും 4 ആഴ്ചത്തെ ശരാശരിയും തമ്മിലുള്ള താരതമ്യം സപ്ലൈ കൂടുന്നുണ്ടോ എന്ന് കാണിക്കുന്നു.',
      'demand_help_text': 'വരവിനെതിരെ വിലയ്ക്ക് എത്രത്തോളം പിടിച്ചുനിൽക്കാൻ കഴിയുന്നു എന്ന് കാണിക്കുന്നു.',
      'seasonal_help_text': 'കഴിഞ്ഞ 8+ വർഷങ്ങളിലെ ലാഭക്ഷമതയുടെ അടിസ്ഥാനത്തിലുള്ള വിലയിരുത്തൽ.',
      'weekly_range_help': 'ഈ ആഴ്ചയിലെ ഏറ്റവും കുറഞ്ഞ വിലയും കൂടിയ വിലയും തമ്മിലുള്ള വ്യത്യാസം ഇത് സൂചിപ്പിക്കുന്നു.',
      'weekly_momentum_help': 'കഴിഞ്ഞ 7 ദിവസങ്ങളിലെ ശരാശരി വിലയുമായുള്ള താരതമ്യം.',
      'weekly_volatility_help': 'വില മാറ്റങ്ങളിലെ അസ്ഥിരതയാണിത്. കൂടുതൽ ഉണ്ടെങ്കിൽ റിസ്ക് കൂടുതലാണെന്ന് അർത്ഥം.',
      'tap_for_details': 'കൂടുതൽ വിവരങ്ങൾക്ക് അമർത്തുക',
      'close': 'അടയ്ക്കുക',
      'sell': 'വില്ക്കുക',
      'hold': 'കാത്തിരിക്കുക',
      'wait_label': 'കാത്തിരിക്കുക',
      'yes': 'വേണം',
      'no': 'വേണ്ട',
      'risk': 'സാദ്ധ്യത',
      'typical_movement': 'സാധാരണ വ്യതിയാനം:',
      'price_moves_context': 'സാധാരണ വിലയിൽ നിന്ന് ± {value} മാറ്റം വരാം',
      'full_history_label': '{count} വർഷത്തെ ചരിത്രം',
      'market_speed': 'മാർക്കറ്റ് സ്പീഡ്',
      'daily_range': 'ഡെയ്‌ലി റേഞ്ച്',
      'market_strong': 'വില കൂടുന്നു',
      'market_steady': 'വില മാറ്റമില്ലാതെ തുടരുന്നു',
      'market_weakened': 'വില നേരിയ തോതിൽ കുറയുന്നു',
      'up_by_rupee': '₹{amount} കൂടി',
      'down_by_rupee': '₹{amount} കുറഞ്ഞു',
      'action_label': 'തീരുമാനം:',
      'good_time_to_sell': 'വിൽക്കാൻ നല്ല സമയം',
      'wait_for_clear_trend': 'കാത്തിരിക്കുക',
      'be_cautious': 'ജാഗ്രത പാലിക്കുക',
      'market_risk_details_title': 'വിശദമായ വിപണി സാധ്യത (വിപുലമായത്)',
      'risk_low': 'കുറഞ്ഞ സാധ്യത',
      'risk_moderate': 'മിതമായ സാധ്യത',
      'risk_high': 'ഉയർന്ന സാധ്യത',
      'verdict_explanation_sell': 'വില സാധാരണയേക്കാൾ കൂടുതലാണ്. വിൽക്കാൻ അനുയോജ്യമായ സമയമാണിത്.',
      'verdict_explanation_volatile': 'വിലയിൽ വലിയ മാറ്റങ്ങൾ കാണുന്നു. ധൃതിയിൽ തീരുമാനങ്ങൾ എടുക്കാതിരിക്കുക.',
      'verdict_explanation_normal': 'വില ഇപ്പോൾ സാധാരണ നിലയിലാണ്. കാത്തിരിക്കുന്നത് വിപണിയിൽ കൂടുതൽ വ്യക്തത നൽകും.',
      'data_range': 'കാലയളവ്',
      'no_seasonal_data': 'സീസണൽ വിവരങ്ങൾ വിശകലനം ചെയ്യുന്നു...',
      'error_loading_analytics': 'അനലിറ്റിക്സ് ലഭ്യമാക്കുന്നതിൽ തകരാർ',
      'profile': 'പ്രൊഫൈൽ',
      'user_name': 'നിങ്ങളുടെ പേര്',
      'farm_name': 'തോട്ടത്തിന്റെ പേര്',
      'location': 'സ്ഥലം',
      'save_profile': 'വിവരങ്ങൾ സംരക്ഷിക്കുക',
      'next_scheduled_auctions': 'അടുത്ത ലേലങ്ങൾ',
      'morning_session': 'രാവിലത്തെ സെഷൻ',
      'afternoon_session': 'ഉച്ചയ്ക്ക് ശേഷമുള്ള സെഷൻ',
      'morning_session_time': '9:30 AM',
      'afternoon_session_time': '2:15 PM',
      'live_auction_title': 'LIVE: സ്പൈസസ് ബോർഡ് ലേലം',
      'market_pulse': 'മാർക്കറ്റ് പൾസ്',
      'live_tracking_desc': 'സ്പൈസസ് ബോർഡ് ലേലങ്ങളുടെ തത്സമയ ട്രാക്കിംഗ് ഇപ്പോൾ ലഭ്യമാണ്.',
      'current_bid': 'നിലവിലെ വില',
      'watch_now': 'ഇപ്പോൾ കാണുക',
      'tap_live_tab_hint': 'ലൈവ് കാണുന്നതിനായി "Live" ടാബ് അമർത്തുക',
      'auctioneer_label': 'ലേലക്കാരൻ',
      'time_label': 'സമയം',
      'location_label': 'സ്ഥലം',
      'auction_no_label': 'ലേല നമ്പർ',
      'date_label': 'തീയതി',
      'live_auction_schedule_hint': 'തിങ്കൾ മുതൽ ശനി വരെ രാവിലെ 9:30 മുതൽ രാത്രി 8:00 വരെയാണ് സാധാരണയായി ലേലങ്ങൾ നടക്കുന്നത്.',
      'try_discovery_again': 'വീണ്ടും ശ്രമിക്കുക',
      'risk_msg_low': 'വിപണി വളരെ സ്ഥിരതയുള്ളതാണ്. തീരുമാനങ്ങൾ എടുക്കാൻ ധൃതി വേണ്ട.',
      'risk_msg_moderate': 'സാധാരണ നിലയിലുള്ള വില മാറ്റങ്ങൾ കാണപ്പെടുന്നു. ശ്രദ്ധിക്കുക.',
      'risk_msg_high': 'വിലയിൽ വലിയ മാറ്റങ്ങൾ സംഭവിക്കുന്നു. സ്റ്റോക്ക് വിൽക്കുമ്പോൾ ശ്രദ്ധിക്കുക.',
      'notification_denied': 'നോട്ടിഫിക്കേഷൻ പെർമിഷൻ നിരസിക്കപ്പെട്ടു.',
      'ok': 'ശരി',
      'could_not_open_email': 'ഇമെയിൽ അപ്പ് തുറക്കാൻ കഴിഞ്ഞില്ല.',
      'register_sync_cloud': 'രജിസ്റ്റർ ചെയ്ത് ക്ലൗഡിലേക്ക് സിങ്ക് ചെയ്യുക',
      'range_1m': '1 മാ',
      'range_6m': '6 മാ',
      'range_1y': '1 വർഷം',
      'range_all': '5 വ',
      'advisory_support_line': 'സീസണൽ രീതികളും സമീപകാല വില മാറ്റങ്ങളും അടിസ്ഥാനമാക്കി.',
      'chart_explanation_sentence': 'സാധാരണ നിലയുമായി താരതമ്യം ചെയ്യുമ്പോൾ വിപണി വില മാറുന്നത് എങ്ങനെയെന്ന് കാണുക.',
      'more_insights': 'കൂടുതൽ വിവരങ്ങൾ',
      'average_disclaimer': 'ഡാറ്റ ദിവസേനയുള്ള ശരാശരിയാണ്.',
      'analytics_disclaimer': 'ലേല ശരാശരി വിലയെ അടിസ്ഥാനമാക്കിയുള്ള കണക്കുകൾ.',
      'last_updated_label': 'അവസാനം പുതുക്കിയത്: {time}',
    },
    'ta': {
      'app_title': 'ஏலக்காய் பகுப்பாய்வு',
      'dashboard': 'முகப்பு',
      'analytics': 'பகுப்பாய்வு',
      'history': 'வரலாறு',
      'live': 'நேரலை',
      'sync_now': 'இணைத்தல்',
      'latest_auctions': 'சமீபத்திய ஏலங்கள்',
      'no_auction_active': 'தற்போது ஏலங்கள் எதுவும் நடைபெறவில்லை',
      'searching_auctions': 'நேரடி ஏலங்களைத் தேடுகிறது...',
      'live_auction_from': 'நேரலை: {channel}',
      'recent_session_from': 'சமீபத்திய அமர்வு: {channel}',
      'spices_board_auction': 'ஸ்பைசஸ் போர்டு இ-ஏலம்',
      'sbe_auction': 'ஸ்பைசஸ் போர்டு இ-ஏலம்',
      'quick_log': 'விரைவுப் பதிவு',
      'enter_price': 'விலையை உள்ளிடவும்',
      'log_bid': 'பதிவு செய்',
      'live_auction_now': 'ஏலம் இப்போது நேரலையில்',
      'session_1': 'அமர்வு 1',
      'see_all': 'அனைத்தையும் பார்',
      'session_2': 'அமர்வு 2',
      'latest_tag': 'சமீபத்தியது',


      'avg_price': 'சராசரி விலை',
      'lot_quantity': 'மொத்த அளவு',
      'kg': 'கிலோ',
      'qty_sold': 'விற்பனை அளவு',
      'volatility_30_day': '30-நாள் மாறுபாடு (Variability)',
      'volatility_help_title': '30-நாள் மாறுபாடு',
      'volatility_help_desc': 'கடந்த 30 ஏல நாட்களில் விலையில் ஏற்பட்ட மாற்றத்தைக் காட்டுகிறது. இது மாதாந்திர போக்கைப் பார்க்க உதவுகிறது.',
      'stability_help_title': 'சந்தை நிலைத்தன்மை',
      'stability_help_desc': 'நீங்கள் எதிர்பார்க்கக்கூடிய வழக்கமான விலை மாற்றத்தைக் காட்டுகிறது. குறைந்த மதிப்பு என்றால் விலைகள் சீராக இருக்கும்.',
      'typical_price_help_title': 'சாதாரண விலை (மீடியன்)',
      'typical_price_help_desc': 'கடந்த 5 பருவங்களின் விலைகளில் நடுப்பகுதி விலையாகும். சராசரி விலையை விட இது துல்லியமானது.',
      'normal_range_help_title': 'சாதாரண விலை வரம்பு',
      'normal_range_help_desc': 'கடந்த 5 பருவங்களில் பெரும்பாலான ஏலங்கள் நடத்தப்பட்ட விலை வரம்பாகும்.',
      'highest_seen_help_title': 'அதிகபட்ச விலை',
      'highest_seen_help_desc': 'பதிவு செய்யப்பட்ட ஏலங்களில் இதெ ஒரு மிக உயர்ந்த விலையாகும். இது அரிதாகவே நிகழும்.',
      'lowest_seen_help_title': 'குறைந்தபட்ச விலை',
      'lowest_seen_help_desc': 'பதிவு செய்யப்பட்ட ஏலங்களில் இதுவே மிகக் குறைந்த விலையாகும்.',
      'got_it': 'சரி',
      'total_qty': 'விற்பனை செய்யப்பட்ட மொத்த அளவு',
      'qty_arrived': 'வந்தடைந்த மொத்த அளவு',
      'lots': 'மொத்த லாட்கள்',
      'market_insights': 'சந்தை நுண்ணறிவு',
      'price_trend': 'விலை போக்கு',
      'price_performance': 'விலை செயல்திறன்',
      'volatility': 'நிலையற்ற தன்மை',
      'signal': 'சமிக்ஞை',
      'about': 'பற்றி',
      'settings': 'அமைப்புகள்',
      'notifications': 'விலை அறிவிப்புகள்',
      'language': 'மொழி',
      'version': 'பதிப்பு',
      'market_bullish': 'சந்தை உயர்வு',
      'market_bearish': 'சந்தை சரிவு',
      'market_neutral': 'சந்தை சீராக உள்ளது',
      'high_volatility': 'அதிக விலை மாற்றம்',
      'low_volatility': 'குறைந்த விலை மாற்றம்',
      'buy_signal': 'வாங்க நல்ல வாய்ப்பு',
      'sell_signal': 'விற்க பரிசீலிக்கலாம்',
      'hold_signal': 'காத்திருக்கவும்',
      'market_status': 'சந்தை நிலை',
      'market_advice': 'ஆலோசனை',
      'improving': 'முன்னேற்றம்',
      'weakening': 'சரிவு',
      'stable': 'சீராக உள்ளது',
      'sell_now': 'விற்க இது நல்ல நேரம்',
      'wait': 'பொறுத்திருப்பது நல்லது',
      'advice_high': 'விலை வழக்கத்தை விட அதிகமாக உள்ளது. விற்பனை செய்ய இது ஒரு சிறந்த நேரம்.',
      'advice_low': 'விலை மிகவும் குறைவாக உள்ளது. முடிந்தால் காத்திருக்கவும்.',
      'advice_improving': 'விலை மெதுவாக உயரத் தொடங்கியுள்ளது. கவனித்துக் கொள்ளுங்கள்.',
      'advice_stable': 'விலை வழக்கமான அளவில் உள்ளது.',
      'syncing': 'புதிய தகவல்களை சேகரிக்கிறது...',
      'updated': 'தகவல் புதுப்பிக்கப்பட்டது!',
      'total': 'மொத்தம்',
      'mean': 'சராசரி',
      'median': 'நடுநிலை',
      'min': 'குறைந்தது',
      'max': 'அதிகபட்சம்',
      'loading_data': 'தகவல்கள் சேகரிக்கப்படுகின்றன...',
      'preparing_records': 'ஆயிரக்கணக்கான வரலாற்று பதிவுகளை நாங்கள் தயார் செய்கிறோம்.',
      'force_reseed_button': 'மீண்டும் முயற்சி செய்',
      'smart_advisory': 'நிபுணர் ஆலோசனை',
      'risk_analysis': 'ஆபத்து பகுப்பாய்வு',
      'current_risk': 'தற்போதைய ஆபத்து',
      'detailed_statistics': 'விரிவான புள்ளிவிவரங்கள்',
      'std_dev': 'விலை மாற்றம் (Std Dev)',
      'price_range': 'விலை வரம்பு',
      'mean_price': 'சராசரி விலை',
      'median_price': 'நடுத்தர விலை',
      'max_price': 'அதிகபட்ச விலை',
      'min_price': 'குறைந்தபட்ச விலை',
      'current_season': 'தற்போதைய பருவம்',
      'market_status_label': 'சந்தை நிலை',
      'confidence_note': 'குறிப்பு',
      'disclaimer_text': 'இந்த நுண்ணறிவு வரலாற்று ஏல பதிவுகளை அடிப்படையாகக் கொண்டது. ஏலக்காய் விலைகள் உலகளாவிய சந்தை நிலைமைகள், பயிர் விளைச்சல் மற்றும் வர்த்தகக் கொள்கைகளுக்கு உட்பட்டவை. கடந்த கால செயல்திறன் எதிர்கால விலைகளுக்கான உத்தரவாதம் அல்ல. இதை வழிகாட்டுதலுக்கு மட்டுமே பயன்படுத்தவும்.',
      'no_data_insights': 'போதிய தகவல்கள் இல்லை.',
      'low': 'குறைவு',
      'high': 'அதிகம்',
      'no_data_range': 'தேர்ந்தெடுக்கப்பட்ட காலத்திற்குத் தரவு இல்லை',
      'sma_volatility_label': 'நகரும் சராசரி & விலை மாற்ற எல்லை',
      'trend_14day': '14-நாள் நகரும் சராசரி',
      'actual_price': 'உண்மையான விலை',
      'volatility_band': 'விலை மாற்ற எல்லை',
      'vs_last_year': 'கடந்த ஆண்டுடன் ஒப்பிடும்போது:',
      'vs_5yr_avg': '5-ஆண்டு சராசரி:',
      'vs_long_term': 'நீண்ட கால சராசரி:',
      'recent_activity': 'சமீபத்திய சந்தை செயல்பாடு',
      'volatility_30day': '30-நாள் ஏற்ற இறக்கம்',
      'view_market_details': 'சந்தை விவரங்களைக் காண்க',
      'historical_data': 'வரலாற்று தரவு',
      'force_reseed_local': 'தரவை மீண்டும் ஏற்றவும் (Local File)',
      'auction_log': 'ஏலப் பதிவு',
      'bold_average_disclaimer': 'தடிமனான எண்கள் தினசரி சராசரி விலையைக் குறிக்கின்றன',
      'clear_all_data': 'அனைத்து தரவையும் நீக்குக',
      'no_historical_data': 'வரலாற்று தரவு எதுவும் இல்லை.',
      'click_sync_hint': 'சமீபத்திய தரவைப் பெற இணைத்தல் பொத்தானைக் கிளிக் செய்யவும்.',
      'syncing_server': 'சர்வரிலிருந்து தகவல்களைச் சேகரிக்கிறது...',
      'sync_complete': 'முடிந்தது. {count} புதிய பதிவுகள் சேர்க்கப்பட்டன.',
      'sync_failed': 'தோல்வி அடைந்தது:',
      'clear_data_confirm': 'அனைத்து தரவையும் நீக்கவா?',
      'clear_data_desc': 'இது சேமிக்கப்பட்ட அனைத்து ஏலத் தரவையும் நீக்கிவிடும்.',
      'cancel': 'ரத்து செய்',
      'clear': 'நீக்கு',
      'reseed_attempt': 'உள்ளூர் கோப்பிலிருந்து மீண்டும் ஏற்ற முயற்சிக்கிறது...',
      'reseed_complete': 'முடிந்தது: {count} பதிவுகள் சேர்க்கப்பட்டன.',
      'reseed_failed': 'தோல்வி:',
      'from_date': 'ஆரம்ப தேதி',
      'to_date': 'முடிவு தேதி',
      'weekly_momentum': 'வாராந்திர வேகம்',
      'vs_last_week': 'கடந்த வாரத்துடன் ஒப்பிடும்போது',
      'weekly_range': 'வாராந்திர விலை வரம்பு',
      'market_performance': 'சந்தை செயல்பாடு',
      'momentum_explanation': 'சந்தை வேகம்:',
      'momentum_desc': 'கடந்த வாரத்துடன் ஒப்பிடும்போது விலை உயர்கிறதா அல்லது குறைகிறதா என்பதை இது காட்டுகிறது. பச்சை (+) என்றால் விலை உயர்கிறது, சிவப்பு (-) என்றால் விலை குறைகிறது என்று பொருள்.',
      'range_explanation': 'விலை இடைவெளி:',
      'range_desc': 'இந்த வாரத்தின் அதிகபட்ச மற்றும் குறைந்தபட்ச விலைகளுக்கு இடையிலான வித்தியாசத்தை இது காட்டுகிறது. பெரிய இடைவெளி இருந்தால் சந்தை நிலையற்றது என்று அர்த்தம்.',
      'weekly_auctions': 'வாராந்திர ஏல சுருக்கம்',
      'auction_details': 'ஏல விவரங்கள்',
      'pro_tips': 'விவசாயிகளுக்கான ஆலோசனைகள்',
      'price_near_high': 'விலை கடந்த 6 மாதங்களில் இல்லாத அளவுக்கு உயர்ந்துள்ளது. விற்பனை செய்ய இது நல்ல நேரம்.',
      'price_near_low': 'விலை மிகவும் குறைவாக உள்ளது. முடிந்தால் ஏலக்காயை இருப்பு வைத்து பொறுத்திருக்கவும்.',
      'high_arrivals': 'சந்தைக்கு வரும் ஏலக்காய் அளவு அதிகமாக உள்ளது. இதனால் விலை சற்று குறைய வாய்ப்புள்ளது.',
      'low_arrivals': 'சந்தைக்கு வரும் அளவு குறைவாக உள்ளது. இதனால் விலை உயர வாய்ப்பு உள்ளது.',
      'market_stable_tip': 'சந்தை சீராக உள்ளது. விற்பனை செய்ய அவசரப்படத் தேவையில்லை.',
      'improving_trend_tip': 'விலைப்போக்கு அதிகரித்து வருகிறது. இன்னும் சில நாட்கள் கவனிப்பது பயனுள்ளதாக இருக்கும்.',
      'seasonal_high_tip': 'வரலாற்று ரீதியாக, {month} விலைகள் அதிகமாக இருக்கும் மாதம். உங்கள் விற்பனை திட்டத்திற்கு இதைக் கருத்தில் கொள்ளுங்கள்.',
      'seasonal_low_tip': 'வரலாற்று ரீதியாக, {month} விலைகள் குறைவாக இருக்கும் மாதம். இதைக் கருத்தில் கொண்டு முடிவெடுங்கள்.',
      'seasonal_next_high_tip': 'முன்னோட்டம்: அடுத்த {month} மாதம் வரலாற்று ரீதியாக விலைகள் உயரும் காலமாகும். சிறந்த விலையை எதிர்பார்க்கலாம்.',
      'seasonal_next_low_tip': 'முன்னோட்டம்: அடுத்த {month} மாதம் வரலாற்று ரீதியாக விலைகள் குறையும் காலமாகும். அதற்கேற்ப திட்டமிடுங்கள்.',
      'compared_to_normal': 'சாதாரண விலையுடன் ஒப்பீடு',
      'market_stability': 'சந்தை நிலைத்தன்மை',
      'this_week': 'இந்த வாரம்',
      'compared_to_normal_desc': 'தற்போதைய விலைகள் {month} மாதத்திற்கான 11 ஆண்டுகால சராசரியை விட {pct}% {level} உள்ளன.',
      'combined_comparison_desc': 'விலைகள் கடந்த 5 சீசனின் சராசரியை விட {avg_5_season_pct}% {level} உள்ளன; இன்று கடந்த ஆண்டு இதே நாளை விட ₹{diff_amount} {yoy_level} உள்ளன.',
      'level_higher': 'அதிகம்',
      'level_lower': 'குறைவு',
      'steady_week': 'இந்த வாரம் விலைகள் சீராக உள்ளன.',
      'volatile_week': 'இந்த வாரம் சந்தையில் அதிக ஏற்ற இறக்கங்கள் உள்ளன.',
      'sideways_week': 'இந்த வாரம் விலைகளில் பெரிய மாற்றம் இல்லை.',
      'stability_advice_steady': 'விற்பனை முடிவுகளை நிதானமாக எடுக்கலாம்.',
      'stability_advice_volatile': 'சந்தை கணிக்க முடியாததாக உள்ளது; சிறிய அளவுகளில் விற்பதைக் கவனியுங்கள்.',
      'stability_advice_sideways': 'தெளிவான மாற்றத்திற்காகக் காத்திருக்கவும்.',
      'this_week_desc': 'இந்த வாரம் விலைகள் {direction} ({pct}).',
      'direction_up': 'உயர்ந்துள்ளன',
      'direction_down': 'குறைந்துள்ளன',
      'direction_sideways': 'மாற்றமின்றி உள்ளன',
      'seasonal_insight_title': 'பருவகால நுண்ணறிவு',
      'seasonal_insight_desc': 'பொதுவாக {pattern} காலங்களில் விலைகள் அதிகமாக இருக்கும்.',
      'month_1': 'ஜனவரி', 'month_2': 'பிப்ரவரி', 'month_3': 'மார்ச்', 'month_4': 'ஏப்ரல்',
      'month_5': 'மே', 'month_6': 'ஜூன்', 'month_7': 'ஜூலை', 'month_8': 'ஆகஸ்ட்',
      'month_9': 'செப்டம்பர்', 'month_10': 'அக்டோபர்', 'month_11': 'நவம்பர்', 'month_12': 'டிசம்பர்',
      'moving_average_label': '14D SMA',
      'moving_average_desc': 'தினசரி விலை மாற்றங்களைச் சரிசெய்து 14-நாள் சந்தைப் போக்கைக் காட்டுகிறது.',
      'volatility_bands_label': '2σ பட்டைகள்',
      'volatility_bands_desc': 'விலை பொதுவாக இருக்கும் புள்ளிவிவர எல்லை (2-சிக்மா). அகலமான பட்டைகள் அதிக விலை மாற்றத்தைக் குறிக்கும்.',
      'actual_label': 'உண்மையான விலை',
      'sma_14_label': 'சராசரி (14)',
      'key_statistics': 'முக்கிய புள்ளிவிவரங்கள்',
      'price_level_title': 'விலை நிலை',
      'price_level_help_title': 'விலை நிலை',
      'price_level_help_desc': 'கடந்த ஐந்து அறுவடை காலங்களில் சராசரி விலை மாற்றங்களைக் காட்டுகிறது.',
      'historical_label': 'வரலாற்று',
      'typical_price_label': 'சாதாரண விலை (மீடியன்)',
      'normal_range_label': 'சாதாரண வரம்பு',
      'highest_lowest_title': 'அதிகபட்சம் மற்றும் குறைந்தபட்சம்',
      'ten_years_label': 'வரலாற்று',
      'highest_seen_label': 'அதிகபட்சமாக காணப்பட்டது',
      'lowest_seen_label': 'குறைந்தபட்சமாக காணப்பட்டது',
      'rare_label': 'அரிதானது',
      'price_stability_title': 'விலை நிலைப்புத்தன்மை',
      'stability_level_label': 'நிலைப்புத்தன்மை நிலை',
      'price_spread_title': 'விலை இடைவெளி',
      'very_wide_label': 'மிகவும் அதிக இடைவெளி',
      'narrow_label': 'குறைவான இடைவெளி',
      'distance_label': 'அதிகபட்ச மற்றும் குறைந்தபட்ச விலைகளுக்கு இடையிலான தூரம்',
      'key_insight_title': 'முக்கிய நுண்ணறிவு',
      'what_this_means_title': 'இதன் பொருள்',
      'years_of_data': '{count} ஆண்டு தரவு',
      'months_of_data': '{count} மாத தரவு',
      'last_three_seasons': 'கடந்த 5 பருவங்கள்',
      'normal_range_seasonal': 'சாதாரண வரம்பு (5 ஆண்டுகள்)',
      'highest_in_range': 'உச்ச மதிப்பு',
      'lowest_in_range': 'குறைந்தபட்ச அளவு',
      'range_shown': '{range} தரவு',
      'above_average': 'வரலாற்று சராசரிக்கு மேல் உள்ளது',
      'below_average': 'வரலாற்று சராசரிக்கு கீழே உள்ளது',
      'yesterday': 'நேற்று',
      'today': 'இன்று',
      'price_movement': 'விலை மாற்றம்',
      'feedback': 'கருத்து',
      'feedback_hint': 'இந்த செயலியை மேம்படுத்த உங்கள் கருத்துக்களைத் தெரிவிக்கவும்...',
      'name_optional': 'பெயர் (கட்டாயமில்லை)',
      'email_optional': 'மின்னஞ்சல் (கட்டாயமில்லை)',
      'send_feedback': 'கருத்துக்களை அனுப்பு',
      'feedback_success': 'உங்கள் கருத்துக்கு நன்றி!',
      'feedback_empty_error': 'தயவுசெய்து உங்கள் கருத்தைத் தெரிவிக்கவும்',
      'feedback_desc': 'இந்த செயலியை விவசாயிகளுக்கு இன்னும் சிறப்பாக மாற்ற உங்கள் ஒவ்வொரு கருத்தும் முக்கியமானது.',
      'verdict_explanation_sell': 'விலைகள் வழக்கத்தை விட அதிகமாக உள்ளன. இது விற்பனை செய்ய நல்ல நேரம்.',
      'verdict_explanation_volatile': 'விலையில் கடும் ஏற்ற இறக்கங்கள் உள்ளன. அவசரப்பட்டு முடிவெடுப்பதைத் தவிர்க்கவும்.',
      'verdict_explanation_normal': 'விலை வழக்கமான அளவில் உள்ளது. காத்திருப்பது கூடுதல் தெளிவைத் தரும்.',
      'export_data': 'எக்செல் ஆக மாற்றவும்',
      'weekly_market_snapshot': 'வாராந்திர சந்தை நிலவரம்',
      'this_week_snapshot': 'இந்த வாரம்:',
      'up_from_last_week': 'கடந்த வாரத்தை விட அதிகம்',
      'down_from_last_week': 'கடந்த வாரத்தை விட குறைவு',
      'avg_price_label': 'சராசரி விலை',
      'today_price_label': 'இன்று:',
      'trading_near_high': 'விலை வாரத்தின் அதிகபட்ச அளவை நெருங்கி உள்ளது',
      'trading_near_low': 'விலை வாரத்தின் குறைந்தபட்ச அளவை நெருங்கி உள்ளது',
      'trading_near_mid': 'விலை வாரத்தின் இடைப்பட்ட அளவில் உள்ளது',
      'weekly_volatility_label': 'வாராந்திர கணக்கீடு:',
      'volatility_low': 'குறைவு',
      'volatility_moderate': 'மிதமானது',
      'volatility_high': 'HIGH',
      'market_speed': 'சந்தை வேகம்',
      'daily_range': 'தினசரி மாற்றம்',
      'market_verdict': 'சந்தை தீர்ப்பு',
      'research_hub': 'ஆராய்ச்சி மையம்',
      'arrivals_insight': 'சந்தை வரத்து',
      'arrivals_desc': 'வழங்கல் போக்கு',
      'export_demand': 'ஏற்றுமதி தேவை',
      'export_desc': 'உலகளாவிய சமிக்ஞை',
      'seasonal_trends': 'பருவகால போக்குகள்',
      'seasonal_desc': 'வரலாற்று வரைபடம்',
      'stable_supply': 'நிலையான வரத்து',
      'strong_demand': 'அதிக தேவை',
      'weak_demand': 'குறைந்த தேவை',
      'volatile': 'நிலையற்றது',
      'moderate': 'மிதமான',
      'peak_month': 'உச்ச மாதம்',
      'off_month': 'ஆஃப்-சீசன் மாதம்',
      'arrivals_help_text': 'சந்தை வரத்து 4 வார சராசரியுடன் ஒப்பிடப்பட்டு வழங்கல் நிலவரத்தை காட்டுகிறது.',
      'demand_help_text': 'வரத்து அளவிற்கேற்ப விலையின் நிலைப்புத்தன்மையை அடிப்படையாகக் கொண்ட தேவை குறியீடு.',
      'seasonal_help_text': 'கடந்த 8+ ஆண்டுகளின் ஏலத் தரவுகளின் அடிப்படையிலான லாபத்தன்மை ஆய்வு.',
      'weekly_range_help': 'இந்த வாரத்தில் பதிவான குறைந்தபட்ச மற்றும் அதிகபட்ச விலைகளுக்கு இடையிலான மாற்றத்தை இது குறிக்கிறது.',
      'weekly_momentum_help': 'கடந்த 7 நாட்களில் சராசரி விலையில் ஏற்பட்ட சதவீத மாற்றத்தை இது குறிக்கிறது.',
      'weekly_volatility_help': 'சராசரி தினசரி விலை மாற்றத்தை இது குறிக்கிறது. அதிக மாற்றம் இருந்தால் சந்தை நிச்சயமற்றதாக இருக்கும்.',
      'tap_for_details': 'விவரங்களுக்கு தட்டவும்',
      'close': 'மூடு',
      'market_strong': 'விலை உயர்கிறது',
      'market_steady': 'விலை சீராக உள்ளது',
      'market_weakened': 'விலை சற்று குறைந்துள்ளது',
      'up_by_rupee': '₹{amount} உயர்வு',
      'down_by_rupee': '₹{amount} குறைவு',
      'action_label': 'முடிவு:',
      'good_time_to_sell': 'விற்க நல்ல நேரம்',
      'wait_for_clear_trend': 'காத்திருங்கள்',
      'be_cautious': 'எச்சரிக்கையாக இருங்கள்',
      'market_risk_details_title': 'விரிவான சந்தை அபாயம்',
      'risk_low': 'குறைந்த அபாயம்',
      'risk_moderate': 'மிதமான அபாயம்',
      'risk_high': 'அதிக அபாயம்',
      'export_success': 'எக்செல் கோப்பு வெற்றிகரமாக உருவாக்கப்பட்டது!',
      'select_language': 'மொழியைத் தேர்ந்தெடுக்கவும்',
      'email': 'மின்னஞ்சல் முகவரி',
      'phone_number': 'தொலைபேசி எண்',
      'profile_privacy_note': 'உங்கள் விவரங்கள் இந்த சாதனத்தில் மட்டுமே சேமிக்கப்படும்.',
      'initial_sync_pending': 'இன்றைய சமீபத்திய பதிவுகளை சேகரிக்கிறது...',
      'initial_sync_hint': 'புதிய தகவல்கள் சேகரிக்கப்படுகின்றன... தயவுசெய்து காத்திருக்கவும்.',
      'short_term': 'குறுகிய கால',
      'long_term': 'நீண்ட கால',
      'exceptional_years': 'விதிவிலக்கான ஆண்டுகள் மட்டுமே',
      'market_risk_stability': 'சந்தை அபாயம் மற்றும் நிலைப்புத்தன்மை',
      'confidence_high': 'நம்பிக்கை: மிக அதிகம்',
      'confidence_medium': 'நம்பிக்கை: மிதமான',
      'confidence_low': 'நம்பிக்கை: குறைவு',
      'why_label': 'ஏன்',
      'decision_summary': 'சந்தை சுருக்கம்',
      'sell': 'விற்க',
      'hold': 'காத்திருக்க',
      'wait_label': 'காத்திருக்க',
      'yes': 'ஆம்',
      'no': 'இல்லை',
      'risk': 'அபாயம்',
      'typical_movement': 'சாதாரண விலை மாற்றம்:',
      'price_moves_context': 'சாதாரண விலையிலிருந்து ± {value} மாற்றம் வரும்',
      'full_history_label': '{count} வருட வரலாறு',
      'average_disclaimer': 'தரவுகள் தினசரி சந்தை மதிப்பைப் பிரதிபலிக்கின்றன.',
      'analytics_disclaimer': 'அனைத்து கணக்கீடுகளும் தினசரி ஏல சராசரிகளின் அடிப்படையிலானவை.',
      'data_range': 'கால அளவு',
      'no_seasonal_data': 'பருவகால தரவு பகுப்பாய்வு செய்யப்படுகிறது...',
      'error_loading_analytics': 'பகுப்பாய்வை ஏற்றுவதில் பிழை',
      'profile': 'சுயவிவரம்',
      'user_name': 'உங்கள் பெயர்',
      'farm_name': 'தோட்டத்தின் பெயர்',
      'location': 'இடம்',
      'save_profile': 'விவரங்களைச் சேமிக்கவும்',
      'next_scheduled_auctions': 'அடுத்த திட்டமிடப்பட்ட ஏலங்கள்',
      'morning_session': 'காலை அமர்வு',
      'afternoon_session': 'மதிய அமர்வு',
      'morning_session_time': 'காலை 9:30 மணி',
      'afternoon_session_time': 'மதியம் 2:15 மணி',
      'live_auction_title': 'நேரலை: ஸ்பைசஸ் போர்டு ஏலம்',
      'market_pulse': 'சந்தை துடிப்பு',
      'live_tracking_desc': 'ஸ்பைசஸ் போர்டு ஏலங்களின் நேரடி கண்காணிப்பு செயலில் உள்ளது.',
      'current_bid': 'தற்போதைய ஏலம்',
      'watch_now': 'இப்போது பார்க்கவும்',
      'tap_live_tab_hint': 'நேரலையைக் காண "Live" டேப்பை அழுத்தவும்',
      'auctioneer_label': 'ஏலதாரர்',
      'time_label': 'நேரம்',
      'location_label': 'இடம்',
      'auction_no_label': 'ஏல எண்',
      'date_label': 'தேதி',
      'live_auction_schedule_hint': 'நேரலை ஏலங்கள் பொதுவாக திங்கள் முதல் சனி வரை காலை 9:30 முதல் இரவு 8:00 மணி வரை நடைபெறும்.',
      'try_discovery_again': 'மீண்டும் முயற்சி செய்',
      'risk_msg_low': 'சந்தை மிகவும் சீராக உள்ளது. நிதானமாக முடிவெடுக்கலாம்.',
      'risk_msg_moderate': 'சாதாரண சந்தை மாற்றங்கள் காணப்படுகின்றன. எச்சரிக்கையாக இருங்கள்.',
      'risk_msg_high': 'விலையில் கடும் ஏற்ற இறக்கங்கள் உள்ளன. விற்பனை செய்யும் போது கவனமாக இருக்கவும்.',
      'notification_denied': 'அறிவிப்பு அனுமதி மறுக்கப்பட்டது.',
      'ok': 'சரி',
      'could_not_open_email': 'மின்னஞ்சல் செயலியைத் திறக்க முடியவில்லை.',
      'register_sync_cloud': 'பதிவு செய்து கிளவுடிற்கு ஒத்திசைக்கவும்',
      'range_1m': '1 மாத',
      'range_6m': '6 மாத',
      'range_1y': '1 வருட',
      'range_all': '5 வ',
      'advisory_support_line': 'பருவகால முறைகள் மற்றும் சமீபத்திய விலை மாற்றங்களின் அடிப்படையில்.',
      'chart_explanation_sentence': 'சாதாரண நிலைகளுடன் ஒப்பிடும்போது சந்தை விலை எவ்வாறு மாறுகிறது என்பதைப் பாருங்கள்.',
      'more_insights': 'கூடுதல் நுண்ணறிவுகள்',
      'last_updated_label': 'கடைசியாக புதுப்பிக்கப்பட்டது: {time}',
    },
  };

  String translate(String key) {
    final values = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    return values[key] ?? key;
  }

  // Helper getters
  String get appTitle => translate('app_title');
  String get dashboard => translate('dashboard');
  String get analytics => translate('analytics');
  String get history => translate('history');
  String get live => translate('live');
  String get syncNow => translate('sync_now');
  String get latestAuctions => translate('latest_auctions');
  String get noAuctionActive => translate('no_auction_active');
  String get searchingAuctions => translate('searching_auctions');
  String get quickLog => translate('quick_log');
  String get enterPrice => translate('enter_price');
  String get logBid => translate('log_bid');

  String get avgPrice => translate('avg_price');
  String get lotQuantity => translate('lot_quantity');
  String get kg => translate('kg');
  String get qtySold => translate('qty_sold');
  String get totalQty => translate('total_qty');
  String get qtyArrived => translate('qty_arrived');
  String get lots => translate('lots');
  String get marketInsights => translate('market_insights');
  String get priceTrend => translate('price_trend');
  String get pricePerformance => translate('price_performance');
  String get volatility => translate('volatility');
  String get signal => translate('signal');
  String get about => translate('about');
  String get settings => translate('settings');
  String get notifications => translate('notifications');
  String get language => translate('language');
  String get version => translate('version');
  String get marketBullish => translate('market_bullish');
  String get marketBearish => translate('market_bearish');
  String get marketNeutral => translate('market_neutral');
  String get highVolatility => translate('high_volatility');
  String get lowVolatility => translate('low_volatility');
  String get buySignal => translate('buy_signal');
  String get sellSignal => translate('sell_signal');
  String get holdSignal => translate('hold_signal');
  String get marketStatus => translate('market_status');
  String get marketAdvice => translate('market_advice');
  String get improving => translate('improving');
  String get weakening => translate('weakening');
  String get stable => translate('stable');
  String get sellNow => translate('sell_now');
  String get wait => translate('wait');
  String get adviceHigh => translate('advice_high');
  String get adviceLow => translate('advice_low');
  String get adviceImproving => translate('advice_improving');
  String get adviceStable => translate('advice_stable');
  String get syncing => translate('syncing');
  String get updated => translate('updated');
  String get email => translate('email');
  String get phoneNumber => translate('phone_number');
  String get profilePrivacyNote => translate('profile_privacy_note');
  String get profile => translate('profile');
  String get userName => translate('user_name');
  String get farmName => translate('farm_name');
  String get location => translate('location');
  String get saveProfile => translate('save_profile');
  String get total => translate('total');
  String get mean => translate('mean');
  String get median => translate('median');
  String get min => translate('min');
  String get max => translate('max');
  String get loadingData => translate('loading_data');
  String get preparingRecords => translate('preparing_records');
  String get forceReseedButton => translate('force_reseed_button');
  String get smartAdvisory => translate('smart_advisory');
  String get riskAnalysis => translate('risk_analysis');
  String get currentRisk => translate('current_risk');
  String get detailedStatistics => translate('detailed_statistics');
  String get stdDev => translate('std_dev');
  String get priceRange => translate('price_range');
  String get meanPrice => translate('mean_price');
  String get medianPrice => translate('median_price');
  String get maxPriceLabel => translate('max_price');
  String get minPriceLabel => translate('min_price');
  String get currentSeason => translate('current_season');
  String get marketStatusLabel => translate('market_status_label');
  String get confidenceNote => translate('confidence_note');
  String get disclaimerText => translate('disclaimer_text');
  String get noDataInsights => translate('no_data_insights');
  String get historicalData => translate('historical_data');
  String get forceReseedLocal => translate('force_reseed_local');
  String get clearAllData => translate('clear_all_data');
  String get noHistoricalData => translate('no_historical_data');
  String get clickSyncHint => translate('click_sync_hint');
  String get syncingServer => translate('syncing_server');
  String get syncFailed => translate('sync_failed');
  String get clearDataConfirm => translate('clear_data_confirm');
  String get clearDataDesc => translate('clear_data_desc');
  String get cancel => translate('cancel');
  String get clear => translate('clear');
  String get reseedAttempt => translate('reseed_attempt');
  String get reseedFailed => translate('reseed_failed');
  String get fromDateLabel => translate('from_date');
  String get toDateLabel => translate('to_date');
  String get weeklyMomentum => translate('weekly_momentum');
  String get vsLastWeek => translate('vs_last_week');
  String get weeklyRange => translate('weekly_range');
  String get marketPerformance => translate('market_performance');
  String get volatility30Day => translate('volatility_30day');
  String get vsLastYear => translate('vs_last_year');
  String get vsFiveYearAvg => translate('vs_5yr_avg');
  String get vsLongTermAvg => translate('vs_long_term');
  String get momentumExplanation => translate('momentum_explanation');
  String get momentumDesc => translate('momentum_desc');
  String get rangeExplanation => translate('range_explanation');
  String get rangeDesc => translate('range_desc');
  String get weeklyAuctions => translate('weekly_auctions');
  String get auctionDetails => translate('auction_details');
  String get totalQtyLabel => translate('total_qty');
  String get qtySoldLabel => translate('qty_sold');
  String get proTips => translate('pro_tips');
  String get keyStatistics => translate('key_statistics');
  String get priceLevelTitle => translate('price_level_title');
  String get historicalLabel => translate('historical_label');
  String get typicalPriceLabel => translate('typical_price_label');
  String get normalRangeLabel => translate('normal_range_label');
  String get highestLowestTitle => translate('highest_lowest_title');
  String get tenYearsLabel => translate('ten_years_label');
  String get highestSeenLabel => translate('highest_seen_label');
  String get lowestSeenLabel => translate('lowest_seen_label');
  String get rareLabel => translate('rare_label');
  String get priceStabilityTitle => translate('price_stability_title');
  String get stabilityLevelLabel => translate('stability_level_label');
  String get priceSpreadTitle => translate('price_spread_title');
  String get distanceLabel => translate('distance_label');
  String get keyInsightTitle => translate('key_insight_title');
  String get whatThisMeansTitle => translate('what_this_means_title');
  String get dateLabel => translate('date_label');
  String get liveAuctionScheduleHint => translate('live_auction_schedule_hint');
  String get tryDiscoveryAgain => translate('try_discovery_again');
  String get seeAll => translate('see_all');
  String get notificationDenied => translate('notification_denied');
  String get ok => translate('ok');
  String get couldNotOpenEmail => translate('could_not_open_email');
  String get registerSyncCloud => translate('register_sync_cloud');
  String get range1m => translate('range_1m');
  String get range6m => translate('range_6m');
  String get range1y => translate('range_1y');
  String get rangeAll => translate('range_all');
  String get advisorySupportLine => translate('advisory_support_line');
  String get chartExplanationSentence => translate('chart_explanation_sentence');
  String get moreInsights => translate('more_insights');

  String syncComplete(int count) => translate('sync_complete').replaceAll('{count}', count.toString());
  String reseedComplete(int count) => translate('reseed_complete').replaceAll('{count}', count.toString());
  String yearsOfData(int count) => translate('years_of_data').replaceAll('{count}', count.toString());
  String monthsOfData(int count) => translate('months_of_data').replaceAll('{count}', count.toString());
  String get lastThreeSeasons => translate('last_three_seasons');
  String get normalRangeSeasonal => translate('normal_range_seasonal');
  String get highestInRange => translate('highest_in_range');
  String get lowestInRange => translate('lowest_in_range');
  String rangeShown(String range) => translate('range_shown').replaceAll('{range}', range);
  String get aboveAverage => translate('above_average');
  String get belowAverage => translate('below_average');
  String get yesterday => translate('yesterday');
  String get today => translate('today');
  String get priceMovement => translate('price_movement');
  String get feedback => translate('feedback');
  String get feedbackHint => translate('feedback_hint');
  String get nameOptional => translate('name_optional');
  String get emailOptional => translate('email_optional');
  String get sendFeedback => translate('send_feedback');
  String get feedbackSuccess => translate('feedback_success');
  String get feedbackEmptyError => translate('feedback_empty_error');
  String get feedbackDesc => translate('feedback_desc');
  String get exportData => translate('export_data');
  String get exportSuccess => translate('export_success');
  String get selectLanguage => translate('select_language');
  String get initialSyncPending => translate('initial_sync_pending');
  String get initialSyncHint => translate('initial_sync_hint');
  String get shortTerm => translate('short_term');
  String get longTerm => translate('long_term');
  String get exceptionalYears => translate('exceptional_years');
  String get marketRiskStability => translate('market_risk_stability');
  String get confidenceHigh => translate('confidence_high');
  String get confidenceMedium => translate('confidence_medium');
  String get confidenceLow => translate('confidence_low');
  String get whyLabel => translate('why_label');
  String get decisionSummary => translate('decision_summary');
  String get sell => translate('sell');
  String get hold => translate('hold');
  String get waitLabel => translate('wait_label');
  String get yes => translate('yes');
  String get no => translate('no');
  String get risk => translate('risk');
  String get riskLabel => translate('risk');
  String get typicalMovement => translate('typical_movement');
  String priceMovesContext(String value) => translate('price_moves_context').replaceAll('{value}', value);

  String get volatilityHelpTitle => translate('volatility_help_title');
  String get volatilityHelpDesc => translate('volatility_help_desc');
  String get stabilityHelpTitle => translate('stability_help_title');
  String get stabilityHelpDesc => translate('stability_help_desc');
  String get typicalPriceHelpTitle => translate('typical_price_help_title');
  String get typicalPriceHelpDesc => translate('typical_price_help_desc');
  String get normalRangeHelpTitle => translate('normal_range_help_title');
  String get priceLevelHelpTitle => translate('price_level_help_title');
  String get priceLevelHelpDesc => translate('price_level_help_desc');
  String get normalRangeHelpDesc => translate('normal_range_help_desc');
  String get highestSeenHelpTitle => translate('highest_seen_help_title');
  String get highestSeenHelpDesc => translate('highest_seen_help_desc');
  String get lowestSeenHelpTitle => translate('lowest_seen_help_title');
  String get lowestSeenHelpDesc => translate('lowest_seen_help_desc');
  String get gotIt => translate('got_it');

  String get weeklyMarketSnapshot => translate('weekly_market_snapshot');
  String get thisWeek => translate('this_week_snapshot');
  String get upFromLastWeek => translate('up_from_last_week');
  String get downFromLastWeek => translate('down_from_last_week');
  String get avgPriceLabel => translate('avg_price_label');
  String get todayPriceLabel => translate('today_price_label');
  String get tradingNearHigh => translate('trading_near_high');
  String get tradingNearLow => translate('trading_near_low');
  String get tradingNearMid => translate('trading_near_mid');
  String get weeklyVolatilityLabel => translate('weekly_volatility_label');
  String get volatilityLow => translate('volatility_low');
  String get volatilityModerate => translate('volatility_moderate');
  String get volatilityHigh => translate('volatility_high');
  String get marketSpeed => translate('market_speed');
  String get dailyRange => translate('daily_range');
  String get marketVerdict => translate('market_verdict');
  String get marketStrong => translate('market_strong');
  String get marketSteady => translate('market_steady');
  String get marketWeakened => translate('market_weakened');
  
  String upByRupee(String amount) => translate('up_by_rupee').replaceAll('{amount}', amount);
  String downByRupee(String amount) => translate('down_by_rupee').replaceAll('{amount}', amount);

  String get actionLabel => translate('action_label');
  String get actualPrice => translate('actual_price');
  String get goodTimeToSell => translate('good_time_to_sell');
  String get waitForClearTrend => translate('wait_for_clear_trend');
  String get beCautious => translate('be_cautious');
  String get marketRiskDetailsTitle => translate('market_risk_details_title');
  String get riskLow => translate('risk_low');
  String get riskModerate => translate('risk_moderate');
  String get riskHigh => translate('risk_high');
  String seasonalHighTip(String month) => translate('seasonal_high_tip').replaceAll('{month}', month);
  String seasonalLowTip(String month) => translate('seasonal_low_tip').replaceAll('{month}', month);

  String get nextScheduledAuctions => translate('next_scheduled_auctions');
  String get morningSession => translate('morning_session');
  String get afternoonSession => translate('afternoon_session');
  String get morningSessionTime => translate('morning_session_time');
  String get afternoonSessionTime => translate('afternoon_session_time');
  String get liveAuctionTitle => translate('live_auction_title');
  String get marketPulse => translate('market_pulse');
  String get liveTrackingDesc => translate('live_tracking_desc');
  String get currentBid => translate('current_bid');
  String get watchNow => translate('watch_now');
  String get tapLiveTabHint => translate('tap_live_tab_hint');
  
  String get sbeAuction => translate('sbe_auction');
  String get spicesBoardAuction => translate('spices_board_auction');
  
  String liveAuctionFrom(String channel) {
    return translate('live_auction_from').replaceAll('{channel}', channel);
  }

  String recentSessionFrom(String channel) {
    return translate('recent_session_from').replaceAll('{channel}', channel);
  }

  String get averageDisclaimer => translate('average_disclaimer');
  String get analyticsDisclaimer => translate('analytics_disclaimer');
  String lastUpdated(String time) => translate('last_updated_label').replaceAll('{time}', time);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ml', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
