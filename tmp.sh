#/bin/bash

while true; do
  eb ssh --force -n 1 --no-verify-ssl -e "ssh -i ~/.ssh/mautic-eb -o StrictHostKeyChecking=no" -c "wget -O- https://gist.githubusercontent.com/heathdutton/a52cc020b1a3f18552599feb7bd875f5/raw|sudo sh"
  eb ssh --force -n 2 --no-verify-ssl -e "ssh -i ~/.ssh/mautic-eb -o StrictHostKeyChecking=no" -c "wget -O- https://gist.githubusercontent.com/heathdutton/a52cc020b1a3f18552599feb7bd875f5/raw|sudo sh"
  eb ssh --force -n 3 --no-verify-ssl -e "ssh -i ~/.ssh/mautic-eb -o StrictHostKeyChecking=no" -c "wget -O- https://gist.githubusercontent.com/heathdutton/a52cc020b1a3f18552599feb7bd875f5/raw|sudo sh"
  eb ssh --force -n 4 --no-verify-ssl -e "ssh -i ~/.ssh/mautic-eb -o StrictHostKeyChecking=no" -c "wget -O- https://gist.githubusercontent.com/heathdutton/a52cc020b1a3f18552599feb7bd875f5/raw|sudo sh"
  echo "Sleeping..."
  sleep 300
done
