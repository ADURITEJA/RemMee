from flask import Flask, request, jsonify
from keybert import KeyBERT
import logging

app = Flask(__name__)
kw_model = KeyBERT()  # Load the BERT-based keyword extractor

# Setup logging for debugging
logging.basicConfig(level=logging.INFO)

@app.route('/extract_keywords', methods=['POST'])
def extract_keywords():
    try:
        data = request.json
        text = data.get("text", "").strip()

        if not text:
            return jsonify({"error": "No text provided"}), 400

        # Extract keywords (1-2 word phrases, remove common stopwords)
        keywords = kw_model.extract_keywords(
            text, 
            keyphrase_ngram_range=(1, 2), 
            stop_words='english', 
            top_n=3
        )

        # Select the best keyword (if confidence > 0.2)
        best_keyword = next((kw[0] for kw in keywords if kw[1] > 0.2), "memory")

        logging.info(f"Extracted keyword: {best_keyword}")

        return jsonify({"keyword": best_keyword})

    except Exception as e:
        logging.error(f"Error: {str(e)}")
        return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)