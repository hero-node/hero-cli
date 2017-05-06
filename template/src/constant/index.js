// Provide Two Additional Variables:
// HOME_PAGE --> @see .hero-cli.json#homepage
// NODE_ENV --> the application start environment: development or production

export var PATH = (window.location.origin + process.env.HOME_PAGE);
export var IS_PRODUCTION = process.env.NODE_ENV === 'production';

// You can access variables provided by `src/environments`
export var BACKEND_URL = process.env.backendURL;
