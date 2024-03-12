export const request = (url, options) => {
  return fetch(url, options)
    .then(response => {
      if (!response.ok) {
        throw new Error(response.statusText);
      }

      if (url.endsWith('.json')) {
        return response.json();
      } else {
        return response.text();
      }
    });
}

export const buildFormData = (obj) => {
  return Object.keys(obj).reduce((o,key)=>(o.set(key, obj[key]), o), new FormData());
}
