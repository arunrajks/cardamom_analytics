
import re

def get_keys(content, lang):
    pattern = rf"'{lang}': \{{(.*?)\}},"
    match = re.search(pattern, content, re.DOTALL)
    if not match:
        return set()
    keys = re.findall(r"'(\w+)'\s*:", match.group(1))
    return set(keys)

with open('/Users/arunraj/Documents/Github/cardamom_analytics/lib/src/localization/app_localizations.dart', 'r') as f:
    content = f.read()

en_keys = get_keys(content, 'en')
ml_keys = get_keys(content, 'ml')
ta_keys = get_keys(content, 'ta')

print(f"EN vs ML Missing: {en_keys - ml_keys}")
print(f"ML vs EN Extra: {ml_keys - en_keys}")
print(f"EN vs TA Missing: {en_keys - ta_keys}")
print(f"TA vs EN Extra: {ta_keys - en_keys}")
